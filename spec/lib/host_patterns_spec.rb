require_relative "../../lib/host_patterns"
require "rails_helper"

RSpec.describe "Host Configuration" do
  let(:host_patterns) { HostPatterns::ALLOWED_HOST_PATTERNS }

  # Used only for testing the regex
  def host_allowed?(host)
    host_patterns.any? { |pattern| host =~ /\A#{pattern}?\z/ }
  end

  context "with allowed hosts" do
    it "matches the production admin domain" do
      expect(host_allowed?("admin.forms.service.gov.uk")).to be true
    end

    it "matches environment-specific admin domains" do
      %w[dev staging research].each do |env|
        expect(host_allowed?("admin.#{env}.forms.service.gov.uk")).to be true
      end
    end

    it "matches admin review app domains" do
      expect(host_allowed?("pr-2032.admin.review.forms.service.gov.uk")).to be true
    end

    it "matches runner review app domains" do
      expect(host_allowed?("pr-3023-admin.submit.review.forms.service.gov.uk")).to be true
    end
  end

  context "with blocked hosts" do
    it "doesn't match unrelated domains" do
      ["example.com", "forms.gov.uk", "anything.forms.service.gov.uk", "admin.other-service.gov.uk"].each do |host|
        expect(host_allowed?(host)).to be false
      end
    end

    it "doesn't match incorrectly formatted review app domains" do
      ["admin.pr-123.review.forms.service.gov.uk",
       "pr123.admin.review.forms.service.gov.uk",
       "admin-pr-123.submit.review.forms.service.gov.uk"].each do |host|
        expect(host_allowed?(host)).to be false
      end
    end

    it "doesn't match domains with extra subdomains" do
      ["extra.admin.forms.service.gov.uk",
       "admin.extra.dev.forms.service.gov.uk"].each do |host|
        expect(host_allowed?(host)).to be false
      end
    end
  end
end
