---
redirect_from: /docs/documentation.html
---
# Arbo
HTML Views in Ruby

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

---

### Introduction

Arbo is a alternate template system for [Ruby on Rails Action View](http://guides.rubyonrails.org/action_view_overview.html).
Arbo expresses HTML using a Ruby DSL, which makes it similar to the [Builder](https://github.com/tenderlove/builder) gem for XML.
Arbo is a fork of Arbre, which was extracted from [Active Admin](https://activeadmin.info/).

An example `index.html.arb`:

```ruby
html {
  head {
    title "Welcome page"
  }
  body {
    para "Hello, world"
  }
}
```

The purpose of Arbo is to leave the view as Ruby objects as long as possible,
which allows an object-oriented approach including inheritance, composition, and encapsulation.

### Installation

Add gem `arbo` to your `Gemfile` and `bundle install`.

Arbo registers itself as a Rails template handler for files with an extension `.arb`.

### Tags

Arbo DSL is composed of HTML tags.  Tag attributes including `id` and HTML classes are passed as a hash parameter and the tag body is passed as a block. Most HTML5 tags are implemented, including `script`, `embed` and `video`.

A special case is the paragraph tag, <p>, which is mapped to `para`.

JavaScript can be included by using `script { raw ... }`

To include text that is not immediately part of a tag use `text_node`.

### Components

Arbo DSL can be extended by defining new tags composed of other, simpler tags.
This provides a simpler alternative to nesting partials.
The recommended approach is to subclass Arbo::Component and implement a new builder method.

The builder_method defines the method that will be called to build this component
when using the DSL. The arguments passed into the builder_method will be passed 
into the #build method for you.

For example:

```ruby
class Panel < Arbo::Component
  builder_method :panel

  def build(title, attributes = {})
    super(attributes)

    h3(title, class: "panel-title")
  end
end
```

By default components are `div` tags with an HTML class corresponding to the component class name.  This can be overridden by redefining the `tag_name` method.

Several examples of Arbo components are [included in Active Admin](https://activeadmin.info/12-arbo-components.html)

### Contexts

An [Arbo::Context](http://www.rubydoc.info/gems/arbo/Arbo/Context) is an object in which Arbo DSL is interpreted, providing a root for the Ruby DOM that can be [searched and manipulated](http://www.rubydoc.info/gems/arbo/Arbo/Element). A context is automatically provided when a `.arb` template or partial is loaded. Contexts can be used when developing or testing a component.  Contexts are rendered by calling render_in.

```ruby
html = Arbo::Context.new do
  div "Hello World", id: "my-panel" do
    span "Inside the panel"
    text_node "Plain text"
  end
end

puts html.render_in # =>
```

```html
<div class='panel' id="my-panel">
  <h3 class='panel-title'>Hello World</h3>
  <span>Inside the panel</span>
  Plain text
</div>
```

A context allows you to specify Rails template assigns, aka. 'locals' and helper methods. Templates loaded by Action View have access to all [Action View helper methods](http://guides.rubyonrails.org/action_view_overview.html#overview-of-helpers-provided-by-action-view)

### Background

Similar projects include:
- [Markaby](http://markaby.github.io/), written by \_why the luck stiff.
- [Erector](http://erector.github.io/), developed at PivotalLabs.
- [Fortitude](https://github.com/ageweke/fortitude), developed at Scribd.
- [Inesita](https://inesita.fazibear.me/) (Opal)
- [html_builder](https://github.com/crystal-lang/html_builder) (Crystal)

