defmodule Fractal.Repo.Migrations.CreateEnrollments do
  use Ecto.Migration

  def change do
    create table(:enrollments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, null: false, default: "active"
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :course_id, references(:courses, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:enrollments, [:user_id])
    create index(:enrollments, [:course_id])

    create unique_index(:enrollments, [:user_id, :course_id],
             name: :enrollments_user_id_course_id_index
           )
  end
end
