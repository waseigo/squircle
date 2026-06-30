<img src="./etc/assets/logo.png" width="100" height="100">

# Squircle

An [Elixir](https://elixir-lang.org/) library to generate squircles in SVG
format that can be used to wrap an image, or as a mask for cropping SVG
files.

[Demo](https://obidenticon.overbring.com/)

## Installation

Add `squircle` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:squircle, "~> 1.0"}
  ]
end
```

## Usage

### Wrap an image in a squircle

```elixir
Squircle.image("https://example.com/photo.png", 200)
```

Returns a complete SVG document with the image rendered inside a
squircle-shaped viewport.

Add padding and adjust the curvature:

```elixir
Squircle.image("https://example.com/photo.png", 200, 20, 0.6)
```

### Wrap SVG content in a squircle

```elixir
Squircle.svg_group(~s(<rect width="80" height="80" fill="rebeccapurple" />), 100)
```

Useful for cropping icons, text, or any SVG fragment into a squircle.

### Curvature

The `curvature` parameter controls how rounded the corners are:

```elixir
# Sharp corners (rounded rectangle)
Squircle.image("img.png", 100, 0, 0.0)

# Default curvature (pill-like)
Squircle.image("img.png", 100, 0, 0.8)

# Perfect circle
Squircle.image("img.png", 100, 0, 1.0)
```

### Padding

Padding expands the viewbox around the squircle:

```elixir
Squircle.image("img.png", 100, 10)
```

When combined with `image/5`, the padding area is transparent. For
`svg_group/5`, the padding area shows the SVG's own background.

### Low-level API

For custom integrations, `create/6` returns the raw path primitives:

```elixir
result = Squircle.create(100, 100, 100, 100, 0.8)
result.arc          # corner arc radius
result.path_d       # SVG path "d" attribute
result.path_transform  # SVG transform string
result.viewbox      # SVG viewBox string
```

### Options

Both `image/5` and `svg_group/5` accept an optional keyword list as the
last argument. Supported keys:

- `:id` — a custom pattern ID (a random one is generated if omitted)

## Configuration

No configuration required.

## Documentation

Full docs can be found at <https://hexdocs.pm/squircle>.

This library is used by [IdenticonSvg](https://hexdocs.pm/identicon_svg) to
convert square identicons to squircled SVG identicons. See also the
[discussion thread on elixirforum.com](https://elixirforum.com/t/identiconsvg-generates-identicons-in-svg-format-so-they-can-be-inlined-in-html/54557/1).
