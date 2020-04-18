defmodule App.Repo.Migrations.CreateAccidents do
  use Ecto.Migration

  def change do
    create table(:accidents) do
      add(:year, :integer)
      add(:latitude, :float)
      add(:longitude, :float)
      add(:vb1, :integer)
      add(:vb2, :integer)
      add(:category, :integer)
    end

    create(index(:accidents, [:year]))
    create(index(:accidents, [:vb1]))
    create(index(:accidents, [:vb2]))
    create(index(:accidents, [:category]))
  end
end
