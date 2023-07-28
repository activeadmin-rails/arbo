require 'rails/rails_spec_helper'

ARBO_VIEWS_PATH = File.expand_path("../../templates", __FILE__)

class TestController < ActionController::Base
  append_view_path ARBO_VIEWS_PATH

  def render_empty
    render "arbo/empty"
  end

  def render_simple_page
    render "arbo/simple_page"
  end

  def render_partial
    render "arbo/page_with_partial"
  end

  def render_erb_partial
    render "arbo/page_with_erb_partial"
  end

  def render_with_instance_variable
    @my_instance_var = "From Instance Var"
    render "arbo/page_with_assignment"
  end

  def render_partial_with_instance_variable
    @my_instance_var = "From Instance Var"
    render "arbo/page_with_arb_partial_and_assignment"
  end

  def render_page_with_helpers
    render "arbo/page_with_helpers"
  end
end


describe TestController, "Rendering with Arbo", type: :request do
  let(:body){ response.body }

  it "should render the empty template" do
    get "/test/render_empty"
    expect(response).to be_successful
  end

  it "should render a simple page" do
    get "/test/render_simple_page"
    expect(response).to be_successful
    expect(body).to have_selector("h1", text: "Hello World")
    expect(body).to have_selector("p", text: "Hello again!")
  end

  it "should render an arb partial" do
    get "/test/render_partial"
    expect(response).to be_successful
    expect(body).to eq <<-EOS
<h1>Before Partial</h1>
<p>Hello from a partial</p>
<h2>After Partial</h2>
EOS
  end

  it "should render an erb (or other) partial" do
    get "/test/render_erb_partial"
    expect(response).to be_successful
    expect(body).to eq <<-EOS
<h1>Before Partial</h1>
<p>Hello from an erb partial</p>
<h2>After Partial</h2>
EOS
  end

  it "should render with instance variables" do
    get "/test/render_with_instance_variable"
    expect(response).to be_successful
    expect(body).to have_selector("h1", text: "From Instance Var")
  end

  it "should render an arbo partial with assignments" do
    get "/test/render_partial_with_instance_variable"
    expect(response).to be_successful
    expect(body).to have_selector("p", text: "Partial: From Instance Var")
  end

  it "should render a page with helpers" do
    get "/test/render_page_with_helpers"
    expect(response).to be_successful
    expect(body).to eq <<EOS
<span>before h1 link</span>
<h1><a href="/h1_link_path">h1 link text</a></h1>
<span>before link_to block</span>
<a href="/link_path">  <i class=\"link-class\">Link text</i>
</a><span>at end</span>
EOS
  end
end
