defmodule App.Repo.Migrations.AddIndices do
  use Ecto.Migration

  def change do
    create(index(:accidents, [:year]))
    create(index(:accidents, [:vb1]))
    create(index(:accidents, [:vb2]))
  end
end
