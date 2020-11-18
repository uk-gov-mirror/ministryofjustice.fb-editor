class ApplicationController < ActionController::Base
  def service_metadata
    {
      "service_id" => params[:service_id],
      "service_name" => "Service Name Preview",
      "version_id" => "ac4b45c5-071e-4d07-b5a2-9f0196a5b267",
      "created_at" => "2020-10-09T11:51:46",
      "created_by" => "4634ec01-5618-45ec-a4e2-bb5aa587e751",
      "configuration" => {
        "_id" => "service",
        "_type" => "config.service"
      },
      "pages" => [
        {
          "_id" => "page.start",
          "_type" => "page.start",
          "body" => "You cannot use this form to complain about:\r\n\r\n* the result of a case\r\n* a judge, magistrate, coroner or member of a tribunal\r\n\r\nThis online form is also available in [Welsh (Cymraeg)](https://complain-about-a-court-or-tribunal.form.service.justice.gov.uk/cy).",
          "heading" => "Service #{params[:service_id]}",
          "lede" => "Your complaint will not affect your case.",
          "steps" => [
            "page-2",
            "page.do-you-have-a-case-number"
          ],
          "url" => "/"
        },
        {
          "_id" => "page-2",
          "_type" => "page",
          "body" => "This is page two",
          "url" => "/page-2"
        }
      ],
      "locale" => "en"
    }
  end
end
