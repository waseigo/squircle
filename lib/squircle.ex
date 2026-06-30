# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@overbring.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Squircle do
  require EEx

  @moduledoc """
  Generate parametrizable squircle paths and full SVG documents.

  A squircle is a shape intermediate between a square and a circle — its
  corners are rounded by a parametrizable `curvature` factor (0.0 = round
  rectangle / full square with sharp corners, 1.0 = perfect circle).

  ## Usage

  Two high-level functions produce complete SVG documents:

    * `image/5` — wraps an image URL inside a squircle-clipped SVG
    * `svg_group/5` — wraps arbitrary SVG content inside a squircle-clipped SVG

  For custom integrations, `create/6` returns the raw path primitives (path
  data, viewbox, and transform string).

  ## Curvature

  The `curvature` parameter controls how rounded the corners are:

    * `0.0` — sharp corners (a rounded rectangle with corner radius 0)
    * `0.5` — medium rounding
    * `0.8` — pill-like (the default)
    * `1.0` — perfect circle (when width == height)
  """
  @moduledoc since: "0.1.0"

  defguardp valid_wrap_args?(size, padding, curvature, payload, type, opts)
            when is_number(size) and size > 0 and is_number(padding) and padding >= 0 and
                   is_number(curvature) and curvature >= 0 and curvature <= 1 and
                   is_binary(payload) and type in [:image_uri, :svg_group] and is_list(opts)

  defguardp valid_create_args?(w, h, vw, vh, curvature, rotate)
            when is_number(w) and w > 0 and is_number(h) and h > 0 and is_number(vw) and vw > 0 and
                   is_number(vh) and vh > 0 and is_number(curvature) and curvature >= 0 and
                   curvature <= 1 and is_number(rotate)

  EEx.function_from_string(
    :defp,
    :svg,
    ~s(<svg xmlns="http://www.w3.org/2000/svg" <%= if type == :image_uri do %>xmlns:xlink="http://www.w3.org/1999/xlink" <% end %>shape-rendering="auto" viewBox="<%= viewbox %>" height="100%" width="100%" version="1.1"><%= content %></svg>),
    [:viewbox, :content, :type]
  )

  EEx.function_from_string(
    :defp,
    :viewbox,
    ~s|0 0 <%= c(vw) %> <%= c(vh) %>|,
    [:vw, :vh]
  )

  EEx.function_from_string(
    :defp,
    :squircle_path,
    ~s|<path d="<%= d %>"<%= if transform != "" do %> transform="<%= transform %>"<% end %><%= if id != "" do %> fill="url(#<%= id %>)"<% end %>/>|,
    [:d, :transform, :id]
  )

  EEx.function_from_string(
    :defp,
    :squircle_path_d,
    ~s|M0 <%= c(h/2) %>C0 <%= c(arc) %> <%= c(arc) %> 0 <%= c(w/2) %> 0S <%= w %> <%= c(arc) %> <%= w %> <%= c(h/2) %> <%= c(w - arc) %> <%= h %> <%= c(w/2) %> <%= h %> 0 <%= c(h - arc) %> 0 <%= c(h/2) %>Z|,
    [:w, :h, :arc]
  )

  EEx.function_from_string(
    :defp,
    :squircle_path_transform,
    ~s|<%= if rotate != 0 do %>rotate(<%= rotate %>, <%= c(vw/2) %>, <%= c(vh/2) %>) <% end %><%= if {vw-w, vh-h} != {0, 0} do %>translate(<%= c((vw - w)/2) %>, <%= c((vh - h)/2) %>)<% end %>|,
    [:w, :h, :vw, :vh, :rotate]
  )

  EEx.function_from_string(
    :defp,
    :squircle_image_transform,
    ~s|rotate(<%= -rotate %>, <%= c(vw/2) %>, <%= c(vh/2) %>)<%= if {vw-w, vh-h} != {0, 0} do %> translate(<%= c(-1*(vw - w)/2) %>, <%= c(-1*(vh - h)/2) %>)<% end %>|,
    [:w, :h, :vw, :vh, :rotate]
  )

  EEx.function_from_string(
    :defp,
    :defs_pattern_container,
    ~s|<defs><pattern id="<%= id %>" patternUnits="userSpaceOnUse" width="<%= w %>" height="<%= h %>"><%= payload %></pattern></defs>|,
    [:payload, :w, :h, :id]
  )

  EEx.function_from_string(
    :defp,
    :image_tag,
    ~s|<image xlink:href="<%= href %>" x="0" y="0" width="<%= w %>" height="<%= h %>" />|,
    [:href, :w, :h]
  )

  defp wrap(
        %{type: type, payload: payload} = _content,
        size,
        padding,
        curvature,
        opts
      )
      when valid_wrap_args?(size, padding, curvature, payload, type, opts) do
    vsize = size + 2 * padding
    s = create(size, size, vsize, vsize, curvature, 0)

    id = Keyword.get(opts, :id) || gen_random_string()

    dp =
      type
      |> pattern_payload(payload, size)
      |> defs_pattern_container(size, size, id)

    p = squircle_path(s.path_d, s.path_transform, id)

    svg(s.viewbox, dp <> p, type)
  end

  defp pattern_payload(:image_uri, payload, size), do: image_tag(payload, size, size)
  defp pattern_payload(:svg_group, payload, _size), do: payload

  @doc """
  Generate a complete SVG document wrapping an image inside a squircle.

  The image at `href` is embedded in an SVG `<pattern>` and rendered through
  a squircle-shaped `<path>`, producing a visually cropped result.

  ## Examples

      iex> svg = Squircle.image("https://example.com/img.png", 100)
      iex> String.starts_with?(svg, "<svg")
      true
      iex> String.ends_with?(svg, "</svg>")
      true
      iex> String.contains?(svg, "viewBox")
      true

  With padding and custom curvature:

      iex> svg = Squircle.image("test.png", 50, 10, 0.5)
      iex> String.contains?(svg, ~s(viewBox="0 0 70 70"))
      true
  """
  def image(href, size, padding \\ 0, curvature \\ 0.8, opts \\ [id: nil])
      when is_number(size) and size > 0 and is_number(padding) and padding >= 0 and
             is_number(curvature) and curvature >= 0 and curvature <= 1 and is_binary(href) and
             is_list(opts) do
    wrap(%{type: :image_uri, payload: href}, size, padding, curvature, opts)
  end

  @doc """
  Generate a complete SVG document wrapping SVG content inside a squircle.

  The given SVG fragment is embedded in a `<pattern>` and rendered through
  a squircle-shaped `<path>`. Useful for cropping arbitrary SVG graphics
  (icons, shapes, text) into a squircle.

  ## Examples

      iex> svg = Squircle.svg_group(~s(<rect width="40" height="40" fill="red" />), 100)
      iex> String.starts_with?(svg, "<svg")
      true
      iex> String.ends_with?(svg, "</svg>")
      true
      iex> String.contains?(svg, ~s(<rect width="40" height="40"))
      true
  """
  def svg_group(svg_g, size, padding \\ 0, curvature \\ 0.8, opts \\ [id: nil])
      when is_number(size) and size > 0 and is_number(padding) and padding >= 0 and
             is_number(curvature) and curvature >= 0 and curvature <= 1 and is_binary(svg_g) and
             is_list(opts) do
    wrap(%{type: :svg_group, payload: svg_g}, size, padding, curvature, opts)
  end

  @doc """
  Compute the raw squircle path primitives for the given dimensions.

  Returns a map with four keys:

    * `:arc` — the corner arc radius (derived from size and curvature)
    * `:path_d` — the SVG path `d` attribute string for the squircle outline
    * `:path_transform` — the SVG `transform` attribute string (rotation +
      centering translation)
    * `:viewbox` — the SVG `viewBox` attribute string

  This is the low-level building block used by `image/5` and `svg_group/5`.
  Use it when you need to integrate the squircle path into a custom SVG.

  ## Examples

      iex> result = Squircle.create(100, 100, 100, 100, 0.8)
      iex> Map.keys(result) |> Enum.sort()
      [:arc, :path_d, :path_transform, :viewbox]

      iex> Squircle.create(100, 100, 100, 100, 0).arc
      50.0

      iex> Squircle.create(100, 100, 100, 100, 1).arc
      0.0

      iex> Squircle.create(100, 100, 100, 100, 0.5).viewbox
      "0 0 100 100"
  """
  def create(w, h, vw, vh, curvature \\ 0.8, rotate \\ 0)
      when valid_create_args?(w, h, vw, vh, curvature, rotate) do
    arc = min(w / 2, h / 2) * (1 - curvature)
    pd = squircle_path_d(w, h, arc)
    pt = squircle_path_transform(w, h, vw, vh, rotate)
    vb = viewbox(vw, vh)

    %{arc: arc, path_d: pd, path_transform: pt, viewbox: vb}
  end

  defp c(x, digits \\ 2)

  defp c(x, digits) when is_float(x) do
    xfr = Float.round(x, digits)

    xi =
      xfr
      |> to_string()
      |> Integer.parse()
      |> elem(0)

    (xfr == xi && xi) || xfr
  end

  defp c(x, _) when is_integer(x), do: x

  defp gen_random_string(len \\ 6) when is_integer(len) and len > 0 do
    for _ <- 1..len, into: "", do: <<Enum.random(~c"0123456789abcdefghijklmnopqrstuvwxyz")>>
  end
end
