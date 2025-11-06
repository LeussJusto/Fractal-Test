defmodule Fractal.Repo.Migrations.AddEnrolledAtAndCancelledAtToEnrollments do
  use Ecto.Migration

  def change do
    alter table(:enrollments) do
      add :enrolled_at, :utc_datetime
      add :cancelled_at, :utc_datetime
    end

    # Backfill enrolled_at con el valor de inserted_at para registros existentes
    execute(
      "UPDATE enrollments SET enrolled_at = inserted_at WHERE enrolled_at IS NULL",
      ""
    )
  end
end
