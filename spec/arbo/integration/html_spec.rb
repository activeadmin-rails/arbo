require 'spec_helper'

describe Arbo do

  let(:helpers){ nil }
  let(:assigns){ {} }

  def output_buffer(actx)
    actx.render_in(actx) && actx.output_buffer
  end

  it "should render a single element" do
    actx = arbo {
      span "Hello World"
    }
    html = "<span>Hello World</span>\n"
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end

  it "should render a child element" do
    actx = arbo {
      span do
        span "Hello World"
      end
    }
    html = <<-HTML
<span>
  <span>Hello World</span>
</span>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end

  it "should render an unordered list" do
    actx = arbo {
      ul do
        li "First"
        li "Second"
        li "Third"
      end
    }
    html = <<-HTML
<ul>
  <li>First</li>
  <li>Second</li>
  <li>Third</li>
</ul>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end

  it "should allow local variables inside the tags" do
    actx = arbo {
       first = "First"
       second = "Second"
       ul do
         li first
         li second
       end
    }
    html = <<-HTML
<ul>
  <li>First</li>
  <li>Second</li>
</ul>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end


  it "should add children and nested" do
    actx = arbo {
      div do
        ul
        li do
          li
        end
      end
    }
    html = <<-HTML
<div>
  <ul></ul>
  <li>
    <li></li>
  </li>
</div>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end


  it "should pass the element in to the block if asked for" do
    actx = arbo {
      div do |d|
        d.ul do
          li
        end
      end
    }
    html = <<-HTML
<div>
  <ul>
    <li></li>
  </ul>
</div>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end


  it "should move content tags between parents" do
    actx = arbo {
      div do
        span(ul(li))
      end
    }
    html = <<-HTML
<div>
  <span>
    <ul>
      <li></li>
    </ul>
  </span>
</div>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end

  it "should add content to the parent if the element is passed into block" do
    actx = arbo {
      div do |d|
        d.id = "my-tag"
        ul do
          li
        end
      end
    }
    html = <<-HTML
<div id="my-tag">
  <ul>
    <li></li>
  </ul>
</div>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end

  it "should have the parent set on it" do
    list, item = nil
    arbo {
      list = ul do
        li "Hello"
        item = li "World"
      end
    }
    expect(item.parent).to eq list
  end

  it "should set a string content return value with no children" do
    actx = arbo {
      li do
        "Hello World"
      end
    }
    html = <<-HTML
<li>Hello World</li>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end

  it "should turn string return values into text nodes" do
    node = nil
    arbo {
      list = li do
        "Hello World"
      end
      node = list.children.first
    }
    expect(node).to be_a Arbo::HTML::TextNode
  end

  it "should not render blank arrays" do
    actx = arbo {
      tbody do
        []
      end
    }
    html = <<-HTML
<tbody></tbody>
HTML
    expect(actx.to_s).to eq(html)
    expect(output_buffer actx).to eq(html)
  end

  describe "self-closing nodes" do

    it "should not self-close script tags" do
      actx = arbo {
        script type: 'text/javascript'
      }
      html = "<script type=\"text/javascript\"></script>\n"
      expect(actx.to_s).to eq(html)
      expect(output_buffer actx).to eq(html)
    end

    it "should self-close meta tags" do
      actx = arbo {
        meta content: "text/html; charset=utf-8"
      }
      html = "<meta content=\"text/html; charset=utf-8\"/>\n"
      expect(actx.to_s).to eq(html)
      expect(output_buffer actx).to eq(html)
    end

    it "should self-close link tags" do
      actx = arbo {
        link rel: "stylesheet"
      }
      html = "<link rel=\"stylesheet\"/>\n"
      expect(actx.to_s).to eq(html)
      expect(output_buffer actx).to eq(html)
    end

    Arbo::HTML::Tag::SELF_CLOSING_ELEMENTS.each do |tag|
      it "should self-close #{tag} tags" do
        actx = arbo {
          send(tag)
        }
        html = "<#{tag}/>\n"
        expect(actx.to_s).to eq(html)
        expect(output_buffer actx).to eq(html)
      end
    end

  end

  describe "html safe" do

    it "should escape the contents" do
      actx = arbo {
        span("<br />")
      }
      html = <<-HTML
<span>&lt;br /&gt;</span>
HTML
      expect(actx.to_s).to eq(html)
      expect(output_buffer actx).to eq(html)
    end

    it "should return html safe strings" do
      expect(arbo {
        span("<br />")
      }.to_s).to be_html_safe
    end

    it "should not escape html passed in" do
      actx = arbo {
        span(span("<br />"))
      }
      html = <<-HTML
<span>
  <span>&lt;br /&gt;</span>
</span>
HTML
      expect(actx.to_s).to eq(html)
      expect(output_buffer actx).to eq(html)
    end

    it "should escape string contents when passed in block" do
      actx = arbo {
        span {
          span {
            "<br />"
          }
        }
      }
      html = <<-HTML
<span>
  <span>&lt;br /&gt;</span>
</span>
HTML
      expect(actx.to_s).to eq(html)
      expect(output_buffer actx).to eq(html)
    end

    it "should escape the contents of attributes" do
      actx = arbo {
        span(class: "<br />")
      }
      html = <<-HTML
<span class="&lt;br /&gt;"></span>
HTML
      expect(actx.to_s).to eq(html)
    end

  end

end
