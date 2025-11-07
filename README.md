# Fractal

## INICIAR PROGRAMA

```bash
mix phx.new fractal --no-html --no-assets
```

## DESCARGAR DEPENDENCIAS

```bash
docker-compose run app mix deps.get
```

## MIGRACIONES

```bash
docker-compose run app mix ecto.migrate
```

## TEST

```bash
docker-compose run --rm app mix test test/fractal/accounts   
docker-compose run --rm app mix test test/fractal/courses
docker-compose run --rm app mix test test/fractal/notification

docker-compose run --rm app mix test test/fractal_web/accounts
docker-compose run --rm app mix test test/fractal_web/courses
docker-compose run --rm app mix test test/fractal_web/notification
```

## POSTMAN

URL: http://localhost:4000/api/graphql

### Registrar
```json
{
	"query": "mutation { register(email: \"admin@test.com\", password: \"Admin123!\", firstName: \"Admin\", lastName: \"User\") { token user { id email firstName lastName role } } }"
}
```

### Login
```json
{
	"query": "mutation { login(email: \"admin@test.com\", password: \"Admin123!\") { token user { id email firstName lastName role } } }"
}
```

### Me
```json
{
	"query": "query { me { id email firstName lastName role } }"
}
```

### Crear un curso
```json
{
	"query": "mutation { createCourse(name: \"Introduction to Elixir\", code: \"ELIXIR101\", description: \"Learn the basics of Elixir programming\", capacity: 30) { id name code description capacity availableSlots insertedAt } }"
}
```

### Lista
```json
{
	"query": "query { courses { id name code capacity availableSlots } }"
}
```

### Lista de Solo curso con Cupos
```json
{
	"query": "query { availableCourses { id name code availableSlots } }"
}
```

### Obtener con id
```json
{
	"query": "query { course(id: \"1\") { id name code description capacity availableSlots } }"
}
```

### Inscribirse
```json
{
	"query": "mutation { enrollInCourse(courseId: \"1\") { id status enrolledAt user { id email firstName lastName } course { id name code availableSlots } } }"
}
```

### My Enrollments
```json
{
	"query": "query { myEnrollments { id status enrolledAt course { name code availableSlots } } }"
}
```

### Ver inscripciones
```json
{
	"query": "query { courseEnrollments(courseId: \"1\") { id status enrolledAt user { email firstName lastName } } }"
}
```

### Cancelar
```json
{
	"query": "mutation { cancelEnrollment(enrollmentId: \"1\") { id status cancelledAt course { name availableSlots } } }"
}
```

### Eliminar curso
```json
{
	"query": "mutation { deleteCourse(id: \"1\") { id name code } }"
}
```
