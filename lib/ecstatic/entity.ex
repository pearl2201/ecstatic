defmodule Ecstatic.Entity do
  alias Ecstatic.{Entity, Component, Aspect}
  defstruct [:id, components: []]

  @type id :: String.t
  @type uninitialized_component :: atom()
  @type components :: list(Component.t)
  @type t :: %Entity{
    id: String.t,
    components: components
  }

  @callback default_components() :: [ atom() ]

  defmacro __using__(_options) do
    @quote do
      @behaviour Entity
    end
  end

  def default_components, do: []

  @doc "Creates a new entity"
  @spec new(components) :: t
  def new(components: components) when is_list(components) do
    build(components)
  end
  def new(components) when is_list(components), do: build(components)

  @spec new(uninitialized_component) :: t
  def new(component), do: new(components: [component | default_components() ])

  @spec new :: t
  def new, do: new(components: default_components())

  defp build(components) do
    entity = %Entity{id: id()}
    Enum.reduce(components, entity, fn
      (%Component{} = c, acc) -> Entity.add(acc, c)
      (c, acc) when is_atom(c) -> Entity.add(acc, c.new)
      (c, _acc) -> raise "Could not initialize, #{inspect c} is not a component."
    end)
  end

  def id, do: Ecstatic.ID.new

  @doc "Add an initialized component to an entity"
  @spec add(t, Component.t) :: t
  def add(%Entity{components: components} = entity, %Component{} = component) do
    %{entity | components: [component | components]}
  end

  @doc "Checks if an entity matches an aspect"
  @spec match_aspect?(t, Aspect.t) :: boolean
  def match_aspect?(entity, aspect) do
    Enum.all?(aspect.with, &has_component?(entity, &1)) &&
      ! Enum.any?(aspect.without, &has_component?(entity, &1))
  end

  @doc "Check if an entity has an instance of a given component"
  @spec has_component?(t, uninitialized_component) :: boolean
  def has_component?(entity, component) do
    entity.components
    |> Enum.map(&(&1.type))
    |> Enum.member?(component)
  end

  @spec find_component(t, uninitialized_component) :: Ecs.Component.t | nil
  def find_component(entity, component) do
    Enum.find(entity.components, &(&1.type == component))
  end

end