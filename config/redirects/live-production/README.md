# Legacy service redirects — runbook (live-production)

Five old Form Builder services (built on the legacy `fb-runner-node` image) are
being retired. Instead of keeping each old application running just to bounce
visitors to a newer form, the bounce is moved onto the **ingress** (the piece
that routes an incoming web address to an application). The ingress then returns
a **301 permanent redirect** on its own, so the old application, its network
entry point, and its settings file can be deleted — while the ingress is kept.

> **Never delete the ingress.** It *is* the redirect now. Deleting it also
> removes the DNS record, so the old address would stop working entirely instead
> of redirecting.

## Services and redirect targets

| Service (`<service>`)            | Old host                                                     | Redirects to                                                                                                  |
|----------------------------------|-------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| `apply-financial-deputy`         | apply-financial-deputy.form.service.justice.gov.uk          | https://apply-for-a-property-and-affairs-deputyship-order.form.service.justice.gov.uk                          |
| `apply-financial-deputy-upfront` | apply-financial-deputy-upfront.form.service.justice.gov.uk  | https://apply-for-a-property-and-affairs-deputyship-order.form.service.justice.gov.uk                          |
| `comments-form`                  | comments-form.form.service.justice.gov.uk                   | https://hmcts-givefeedback-form-eng.form.service.justice.gov.uk                                                |
| `same-roof-rule`                 | same-roof-rule.form.service.justice.gov.uk                  | https://www.gov.uk/claim-compensation-criminal-injury/victim-lived-with-attacker-before-october-1979 (GOV.UK) |
| `user-feedback`                  | user-feedback.form.service.justice.gov.uk                   | https://hmcts-saythankyou-form-eng.form.service.justice.gov.uk                                                 |

`same-roof-rule` points at www.gov.uk, not a `*.form.service.justice.gov.uk`
address. That is expected.

The `*-redirect-ingress.yaml` files in this directory are the **source of
truth** for each ingress. Apply them with `kubectl apply -f` (see Step A) so the
file becomes the record of what is live — there is no separate "keep the files in
step by hand" step to forget, and no risk of a typo in a live editor.

## Namespace

```
formbuilder-services-live-production
```

## Rollout order

Do one service fully first: `comments-form`. Only once all its checks pass,
repeat for the remaining four.

Redirect **temporarily (302) first**, verify it, then switch to
permanent (301). A 302 is not cached hard by browsers, so if the target turns
out to be wrong, visitors are not stuck on it, unlike the permanent redirect.

## Step 0 — Back up everything first (before any change)

Take a copy of all four objects, **including the ingress** (which step A will change), before touching anything. Store it somewhere private as the ConfigMap contains private keys:

```
mkdir -p ~/backups
kubectl get ingress/<service>-ingress deployment/<service> service/<service> configmap/fb-<service>-config-map \
  -n formbuilder-services-live-production -o yaml > ~/backups/<service>-legacy.yaml
```

comments-form example
```
kubectl get ingress/comments-form-ingress deployment/comments-form service/comments-form configmap/fb-comments-form-config-map \
  -n formbuilder-services-live-production -o yaml > ~/backups/comments-form-legacy.yaml
```  

Check the backup captured all four:
```
grep 'kind:' ~/backups/<service>-legacy.yaml
```
You should see `Ingress`, `Deployment`, `Service` and `ConfigMap`.

## Step A — Apply the redirect from the file (reversible)

Preview exactly what will change, then apply:

```
kubectl diff  -f config/redirects/live-production/<service>-redirect-ingress.yaml
kubectl apply -f config/redirects/live-production/<service>-redirect-ingress.yaml
```

The `diff` must show the added `permanent-redirect` annotation (plus the
internal `last-applied-configuration` record). Nothing else should be shown.

### Temp redirect first (302), then permanent (301)

For `comments-form`, temporarily swap the annotation in its file to the 302
form, apply, verify (Step B), then swap back to permanent and apply again:

```yaml
# temporary (302) for the first check:
nginx.ingress.kubernetes.io/temporal-redirect: "https://hmcts-givefeedback-form-eng.form.service.justice.gov.uk"
# when happy with temp redirect, implement perm redirect (301):
nginx.ingress.kubernetes.io/permanent-redirect: "https://hmcts-givefeedback-form-eng.form.service.justice.gov.uk"
```

## Step B — Verify the redirect has worked

Check the root host url:

```
curl -I https://<service>.form.service.justice.gov.uk
```

Check a url with a path, confirm old sub-pages redirect as well:

```
curl -I https://<service>.form.service.justice.gov.uk/some-old-page
```

Pass criteria for both (in curl command response):

- Status is **301** (or **302** during the temporary redirect check).
- `location:` header is the **correct** target from the above URL table.
- **No** `sessionId` cookie is set and **no** `x-runtime` header is present.
  Both are emitted by the old legacy runner, so their absence confirms the
  ingress is answering and not the old application.
- Confirm the redirect works to the correct URL


```
curl -I <target URL>
```

Expect a **200**, or a **302** to a start or sign-in page.

Do not delete anything for a service until its checks pass.

## Step C — Scale down, verify, then delete later

Do **not** delete straight away in case a reversion is needed. (The backup from
Step 0 is the safety net.)

1. **Scale to zero, then delete later.** Stop the pods but keep the definitions
   so they can be brought back:
   ```
   kubectl scale deployment <service> --replicas=0 -n formbuilder-services-live-production
   ```
   Re-run the Step B checks. If anything breaks run `kubectl scale deployment
   <service> --replicas=1`. After a few days with no problems, delete:
   ```
   kubectl delete deployment <service> -n formbuilder-services-live-production   # then re-check curl
   kubectl delete service    <service> -n formbuilder-services-live-production   # then re-check curl (most likely to reveal a problem)
   kubectl delete configmap  fb-<service>-config-map -n formbuilder-services-live-production   # then re-check curl
   ```

**Keep:** the ingress, and the `fb-<service>-secrets` secret **if it exists**
(see "Smaller points").

Deleting the service leaves the ingress referring to a service name that no
longer exists. The 301 is designed to fire before the ingress reaches the
service, so the redirect should keep working — but **verify it, do not assume
it**. If the redirect stops, the old address will show an error page instead of
redirecting.

## Smaller points

- **Secret may not exist.** The legacy deployments did **not** load
  `fb-<service>-secrets`, so confirm it exists before relying on "Keep":
  `kubectl get secret -n formbuilder-services-live-production | grep <service>`.
- **Monitoring alerts.** If anything watches these pods, scaling them to zero may
  fire "pod down" alerts. Tell whoever is on call before scaling down.

## Restore steps

**Spot problems quickly.** Run this after every delete, and once a day while the
services are scaled to zero — every line should show `301` and the correct
target:
```
for s in apply-financial-deputy apply-financial-deputy-upfront comments-form same-roof-rule user-feedback; do
  echo "$s -> $(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' https://$s.form.service.justice.gov.uk)"
done
```

Undo the redirect (remove the redirect line from the file first):
```
kubectl apply -f config/redirects/live-production/<service>-redirect-ingress.yaml
```

Undo the scale down:
```
kubectl scale deployment <service> --replicas=1 -n formbuilder-services-live-production
```

If the redirect stops after deleting the old service, recreate a plain service
with the same name and port. It has no matching pods (its `app=<service>`
selector matches nothing) as the redirect never forwards traffic
to it:
```
kubectl create service clusterip <service> --tcp=3000:3000 -n formbuilder-services-live-production
```
If that brings the 301 back, keep it as the placeholder and skip deleting the
service for the other four.

Full restore after deleting — brings back the old pod doing its own 302:
```
kubectl apply -f ~/backups/<service>-legacy.yaml
```
