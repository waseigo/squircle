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
