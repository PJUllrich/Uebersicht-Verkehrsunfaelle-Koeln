defmodule Web do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use Web, :controller
      use Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def form_object do
    quote do
      @me __MODULE__
      use Ecto.Schema
      import Ecto.Changeset, warn: false

      def execute_validations(%Ecto.Changeset{} = changeset) do
        form_data = apply_changes(changeset)

        if changeset.valid? do
          {:ok, change(form_data), form_data}
        else
          {:error, changeset, form_data}
        end
      end
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: Web

      import Plug.Conn
      import Web.Gettext
      import Phoenix.LiveView.Controller

      alias Web.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/web/templates",
        namespace: Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      import Phoenix.LiveView.Helpers

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Web.ErrorHelpers
      import Web.Gettext
      import Web.SharedView
      alias Web.Router.Helpers, as: Routes
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}
      alias Web.Router.Helpers, as: Routes
    end
  end

  def query do
    quote do
      import Ecto.Query
      alias App.{Accident, Repo}
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Web.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
