defmodule FailerWeb.UserLive.Index do
  use FailerWeb, :live_view

  alias Failer.Accounts
  alias Failer.Accounts.User
  require Logger

  @impl true
  def mount(params, session, socket) do
    #    require IEx; IEx.pry();
    Logger.warn("session: #{inspect(session)}")
    {:ok, assign(socket, :users, list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, assign(socket, :users, list_users())}
  end

  @impl true
  def handle_event("crash", params, socket) do
    nil.ok()
    {:noreply, socket}
  end

  @impl true
  def handle_event("assign", params, socket) do
    x = Enum.random(1..99)
    Logger.warn("assigning #{x}")
    {:noreply, assign(socket, :my_data, x)}
  end

  @impl true
  def handle_event("pry", params, socket) do
    Process.send_after(self(), :pry, :timer.seconds(1))
    {:noreply, socket}
  end

  @impl true
  def handle_info(:pry, socket) do
    require IEx
    IEx.pry()
    :ok
    {:noreply, socket}
  end

  defp list_users do
    Accounts.list_users()
  end
end
