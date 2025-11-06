alias Fractal.Accounts.Services.AuthService
alias Fractal.Courses.Services.{CourseService, EnrollmentService}
alias Fractal.Repo

IO.puts("\n Iniciando seeds para Fractal University...")

# Limpiar datos existentes (opcional)
IO.puts(" Limpiando base de datos...")
Repo.delete_all(Fractal.Courses.Schemas.Enrollment)
Repo.delete_all(Fractal.Courses.Schemas.Course)
Repo.delete_all(Fractal.Accounts.Schemas.User)

# USUARIOS
IO.puts("\n Creando usuarios...")

# Estudiantes
{:ok, student1, _token} =
  AuthService.register_user(%{
    email: "juan@student.com",
    password: "password123",
    first_name: "Juan",
    last_name: "Pérez"
  })

{:ok, student2, _token} =
  AuthService.register_user(%{
    email: "maria@student.com",
    password: "password123",
    first_name: "María",
    last_name: "González"
  })

{:ok, student3, _token} =
  AuthService.register_user(%{
    email: "carlos@student.com",
    password: "password123",
    first_name: "Carlos",
    last_name: "Rodríguez"
  })

IO.puts("   ✅ 3 estudiantes creados")

# CURSOS

IO.puts("\n Creando cursos...")

{:ok, math} =
  CourseService.create_course(%{
    name: "Matemáticas I",
    code: "MAT101",
    description: "Cálculo diferencial e integral básico",
    capacity: 30
  })

{:ok, physics} =
  CourseService.create_course(%{
    name: "Física I",
    code: "FIS101",
    description: "Mecánica clásica y leyes de Newton",
    capacity: 20
  })

{:ok, programming} =
  CourseService.create_course(%{
    name: "Programación I",
    code: "PRO101",
    description: "Introducción a la programación con Elixir",
    capacity: 25
  })

IO.puts("    3 cursos creados")

# INSCRIPCIONES

IO.puts("\n  Creando inscripciones...")

{:ok, _enroll1} = EnrollmentService.enroll_user(student1.id, math.id)
{:ok, _enroll2} = EnrollmentService.enroll_user(student1.id, physics.id)
{:ok, _enroll3} = EnrollmentService.enroll_user(student2.id, programming.id)
{:ok, _enroll4} = EnrollmentService.enroll_user(student3.id, math.id)

IO.puts("   4 inscripciones creadas")

# RESUMEN

IO.puts("\n" <> String.duplicate("=", 50))
IO.puts("SEEDS COMPLETADOS!")
IO.puts(String.duplicate("=", 50))
IO.puts("\n Resumen:")
IO.puts("   Usuarios: 3 estudiantes")
IO.puts("   Cursos: 3 cursos")
IO.puts("   Inscripciones: 4 inscripciones")

IO.puts("\n Credenciales de prueba:")
IO.puts("   Email: juan@student.com")
IO.puts("   Email: maria@student.com")
IO.puts("   Email: carlos@student.com")
IO.puts("   Password (todos): password123")

IO.puts("\n Slots disponibles en Redis cargados automáticamente por GenServer")
IO.puts(String.duplicate("=", 50) <> "\n")
