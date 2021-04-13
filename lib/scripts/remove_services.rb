def kubectl(namespace:, config:, target:)
  result = `$(which kubectl) delete #{config} #{target} -n #{namespace}`

  if result.empty?
    puts "Failed to delete #{target} from #{config}"
  else
    puts "Successfully deleted #{target} from #{config}"
  end
end

def delete_deployment(target:, namespace:)
  kubectl(namespace: namespace, config: 'deployment', target: target)
end

def delete_ingress(target:, namespace:)
  kubectl(namespace: namespace, config: 'ingress', target: "#{target}-ingress")
end

def delete_service(target:, namespace:)
  kubectl(namespace: namespace, config: 'service', target: target)
end

def delete_configmaps(target:, namespace:)
  kubectl(namespace: namespace, config: 'configmaps', target: "fb-#{target}-config-map")
end

def delete_secrets(target:, namespace:)
  kubectl(namespace: namespace, config: 'secrets', target: "fb-#{target}-secrets")
end

def delete_service_configurations(target:, namespace:)
  puts '-----------------------------------------'
  delete_deployment(target: target, namespace: namespace)
  delete_ingress(target: target, namespace: namespace)
  delete_service(target: target, namespace: namespace)
  delete_configmaps(target: target, namespace: namespace)
  delete_secrets(target: target, namespace: namespace)
  puts '-----------------------------------------'
end

if ARGV.count > 2
  puts "Too many arguments"
  exit 0
end

namespace, service_to_remove = ARGV

if namespace.nil?
  puts "Namespace is required"
  exit 0
end

if namespace.include?('live-production')
  puts "Nope!"
  exit 0
end

services = `kubectl get pods -n #{namespace}`.split("\n")
services.shift # remove the column names

non_acceptance_tests_services = services.map do |service|
  next if service.include?('acceptance-tests')
  service.split('-')[0...-2].join('-')
end.compact

if service_to_remove
  if non_acceptance_tests_services.include?(service_to_remove)
    delete_service_configurations(target: service_to_remove, namespace: namespace)
  else
    puts "#{service_to_remove} does not exist in #{namespace}"
    exit 0
  end
else
  if services.empty?
    puts "No services to remove in #{namespace}"
  else
    puts "Removing #{non_acceptance_tests_services.count} services"

    non_acceptance_tests_services.each do |target|
      delete_service_configurations(target: target, namespace: namespace)
    end
  end
end
