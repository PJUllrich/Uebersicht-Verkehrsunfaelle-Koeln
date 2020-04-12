defmodule App.Repo.Migrations.CreateAccidents do
  use Ecto.Migration

  def change do
    create table(:accidents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :year, :integer
      add :latitude, :float
      add :longitude, :float
      add :vb1, :integer
      add :vb2, :integer

      timestamps()
    end

  end
end
