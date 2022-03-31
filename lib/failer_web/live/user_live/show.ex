defmodule FailerWeb.UserLive.Show do
  use FailerWeb, :live_view

  alias Failer.Accounts
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("show - in mounting")
    Process.send_after(self(), :crash, :timer.seconds(5))
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, Accounts.get_user!(id))}
  end

  @impl true
  def handle_info(:crash, socket) do
    Logger.debug("show - in crashing")
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end
