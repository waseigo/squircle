defmodule SquircleTest do
  use ExUnit.Case
  doctest Squircle

  describe "curvature bounds" do
    test "rejects curvature > 1" do
      assert_raise FunctionClauseError, fn ->
        Squircle.image("test.png", 100, 0, 1.5)
      end
    end

    test "rejects curvature < 0" do
      assert_raise FunctionClauseError, fn ->
        Squircle.image("test.png", 100, 0, -0.1)
      end
    end

    test "accepts curvature = 0" do
      assert Squircle.image("test.png", 100, 0, 0) =~ "viewBox"
    end

    test "accepts curvature = 1" do
      assert Squircle.image("test.png", 100, 0, 1) =~ "viewBox"
    end
  end

  describe "svg_group curvature bounds" do
    test "rejects curvature > 1" do
      assert_raise FunctionClauseError, fn ->
        Squircle.svg_group("<circle cx=\"10\" cy=\"10\" r=\"5\" />", 100, 0, 2.0)
      end
    end

    test "rejects curvature < 0" do
      assert_raise FunctionClauseError, fn ->
        Squircle.svg_group("<circle cx=\"10\" cy=\"10\" r=\"5\" />", 100, 0, -0.5)
      end
    end
  end

  describe "svg version" do
    test "outputs version 1.1" do
      svg = Squircle.image("test.png", 100)
      assert svg =~ ~s{version="1.1"}
      refute svg =~ ~s{version="1.2"}
    end

    test "wrapper outputs version 1.1" do
      svg = Squircle.svg_group("<g />", 100)
      assert svg =~ ~s{version="1.1"}
    end
  end

  describe "transform attribute" do
    test "omitted when no padding or rotation" do
      svg = Squircle.image("test.png", 100)
      refute svg =~ ~s{transform=""}
      refute svg =~ ~s{transform=" "}
    end

    test "present when padding is used" do
      svg = Squircle.image("test.png", 100, 10)
      assert svg =~ ~s{transform="}
    end
  end

  describe "path closure" do
    test "squircle path ends with Z to formally close the path" do
      result = Squircle.create(100, 100, 100, 100, 0.8)
      assert String.ends_with?(result.path_d, "Z")
    end

    test "closing Z is the last character before any trailing whitespace" do
      result = Squircle.create(50, 100, 60, 110, 0.5)
      assert result.path_d |> String.trim_trailing() |> String.ends_with?("Z")
    end
  end

  describe "image/2 SVG output" do
    test "returns a complete SVG document" do
      svg = Squircle.image("https://example.com/img.png", 100)
      assert String.starts_with?(svg, "<svg")
      assert String.ends_with?(svg, "</svg>")
    end

    test "contains image tag inside pattern" do
      svg = Squircle.image("https://example.com/img.png", 100)
      assert svg =~ ~r{<image xlink:href="https://example.com/img.png"}
    end

    test "contains path with pattern fill" do
      svg = Squircle.image("https://example.com/img.png", 100)
      assert svg =~ ~r{<path d=".*"}
      assert svg =~ ~r{fill="url\(#}
    end

    test "viewbox matches size when no padding" do
      svg = Squircle.image("test.png", 50)
      assert svg =~ ~s{viewBox="0 0 50 50"}
    end

    test "viewbox includes padding" do
      svg = Squircle.image("test.png", 50, 10)
      assert svg =~ ~s{viewBox="0 0 70 70"}
    end
  end

  describe "svg_group/2 SVG output" do
    test "embeds the group inside pattern" do
      svg = Squircle.svg_group(~s{<rect width="40" height="40" fill="red" />}, 100)
      assert svg =~ ~r{<rect width="40" height="40"}
    end

    test "returns a complete SVG document" do
      svg = Squircle.svg_group(~s{<rect width="40" height="40" fill="red" />}, 100)
      assert String.starts_with?(svg, "<svg")
      assert String.ends_with?(svg, "</svg>")
    end
  end

  describe "create/6 output structure" do
    test "returns map with expected keys" do
      result = Squircle.create(100, 100, 100, 100, 0.8)
      assert Map.has_key?(result, :arc)
      assert Map.has_key?(result, :path_d)
      assert Map.has_key?(result, :path_transform)
      assert Map.has_key?(result, :viewbox)
    end

    test "arc scales with size and curvature" do
      r1 = Squircle.create(100, 100, 100, 100, 0)
      r2 = Squircle.create(100, 100, 100, 100, 0.5)
      r3 = Squircle.create(100, 100, 100, 100, 1)
      assert r1.arc > r2.arc
      assert r2.arc > r3.arc
      assert r3.arc == 0.0
    end
  end

  describe "create curvature bounds" do
    test "rejects curvature > 1" do
      assert_raise FunctionClauseError, fn ->
        Squircle.create(100, 100, 100, 100, 1.1)
      end
    end

    test "rejects curvature < 0" do
      assert_raise FunctionClauseError, fn ->
        Squircle.create(100, 100, 100, 100, -0.01)
      end
    end
  end
end
