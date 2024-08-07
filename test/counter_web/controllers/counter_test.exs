defmodule CounterWeb.PageControllerTest do
  use CounterWeb.ConnCase
  import Phoenix.LiveViewTest

  test "connected mount", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Counter: "
  end

  test "increment", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    current = Counter.Count.current()
    assert html =~ "Counter: #{current}"
    assert render_click(view, :inc) =~ "Counter: #{current + 1}"
  end

  test "decrement", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    current = Counter.Count.current()
    assert html =~ "Counter: #{current}"
    assert render_click(view, :dec) =~ "Counter: #{current - 1}"
  end

  test "handle_info/2 count update", %{conn: conn} do
    {:ok, view, disconnected_html} = live(conn, "/")
    current = Counter.Count.current()
    assert disconnected_html =~ "Counter: #{current}"
    assert render(view) =~ "Counter: #{current}"
    send(view.pid, {:count, 2})
    assert render(view) =~ "Counter: 2"
  end

  test "handle_info/2 presence update - joiner", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert html =~ "Connected Clients: 1"

    send(view.pid, %{
      event: "presence_diff",
      payload: %{
        joins: %{"phx-Fhb_dqdqsOCzKQAl" => %{metas: [%{phx_ref: "Fhb_dqdrwlCmfABl"}]}},
        leaves: %{}
      }
    })

    assert render(view) =~ "Connected Clients: 2"
  end

  test "handle_info/2 Presence Update - Leaver", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert html =~ "Connected Clients: 1"

    send(view.pid, %{
      event: "presence_diff",
      payload: %{
        joins: %{},
        leaves: %{"phx-Fhb_dqdqsOCzKQAl" => %{metas: [%{phx_ref: "Fhb_dqdrwlCmfABl"}]}}
      }
    })

    assert render(view) =~ "Connected Clients: 0"
  end
end
