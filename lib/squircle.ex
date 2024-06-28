defmodule Squircle do
  require EEx

  @moduledoc """
  Documentation for `Squircle`.
  """
  @moduledoc since: "0.9.0"

  EEx.function_from_string(
    :defp,
    :svg,
    ~s(<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" shape-rendering="crispEdges" viewBox="<%= viewbox %>" height="100%" width="100%" version="1.2"><%= content %></svg>),
    [:viewbox, :content]
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
    ~s|<path d="<%= d %>" transform="<%= transform %>"<%= if id != "" do %> fill="url(#<%= id %>)"<% end %>/>|,
    [:d, :transform, :id]
  )

  EEx.function_from_string(
    :defp,
    :squircle_path_d,
    ~s|M0 <%= c(h/2) %>C0 <%= c(arc) %> <%= c(arc) %> 0 <%= c(w/2) %> 0S <%= w %> <%= c(arc) %> <%= w %> <%= c(h/2) %> <%= c(w - arc) %> <%= h %> <%= c(w/2) %> <%= h %> 0 <%= c(h - arc) %> 0 <%= c(h/2) %>|,
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
    :defs_pattern_image,
    ~s|<defs><pattern id="<%= id %>" patternUnits="userSpaceOnUse" width="<%= w %>" height="<%= h %>"><image xlink:href="<%= href %>" x="0" y="0" width="<%= w %>" height="<%= h %>" /></pattern></defs>|,
    [:w, :h, :href, :id]
  )

  def image(href, size, padding \\ 0, curvature \\ 0.8, opts \\ [id: nil])
  when is_number(size) and size > 0 and is_number(padding) and padding >= 0 and is_number(curvature) and is_bitstring(href) and is_list(opts)
  do

    vsize = size + 2 * padding
    s = create(size, size, vsize, vsize, curvature, 0)

    id = Keyword.get(opts, :id)
    did = is_nil(id) && gen_random_string() || id
    dpi = defs_pattern_image(size, size, href, did)

    p = squircle_path(s.path_d, s.path_transform, did)

    svg(s.viewbox, dpi <> p)
  end

  def create(w, h, vw, vh, curvature \\ 0.8, rotate \\ 0)
  when is_number(w) and w > 0 and is_number(h) and h > 0 and is_number(vw) and vw > 0 and is_number(vh) and vh > 0 and is_number(curvature) and is_number(rotate)
  do
    arc = min(w / 2, h / 2) * (1 - curvature)
    pd = squircle_path_d(w, h, arc)
    pt = squircle_path_transform(w, h, vw, vh, rotate)
    vb = viewbox(vw, vh)

    %{arc: arc, path_d: pd, path_transform: pt, viewbox: vb}
  end

  def c(x, digits \\ 2)

  def c(x, digits) when is_float(x) do
    xfr = Float.round(x, digits)

    xi =
      xfr
      |> to_string()
      |> Integer.parse()
      |> elem(0)

    (xfr == xi && xi) || xfr
  end

  def c(x, _) when is_integer(x), do: x

  defp gen_random_string(len \\ 6) when is_integer(len) and len > 0 do
    for _ <- 1..len, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyz')>>
  end
end
