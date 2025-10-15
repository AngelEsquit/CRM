# Integración WhatsApp - Quick Start

## ⚡ Cambios Rápidos para Activar el Sistema

### 1. Agregar Imports en main.go

Agrega estos imports al archivo `cmd/server/main.go`:

```go
import (
	// ... tus imports existentes
	"time"
	whatsapp_api "software-backend/internal/api"
	"software-backend/internal/repository"
	whatsapp_service "software-backend/internal/service"
	"software-backend/internal/scheduler"
	appointment_repo "software-backend/internal/repository/appointment"
	patient_repo "software-backend/internal/repository/patient"
)
```

### 2. Inicializar Repos y Servicios

En tu función `main()`, después de inicializar tu base de datos y antes de `e.Start()`:

```go
// Inicializar repositorios de WhatsApp
whatsAppRepo := repository.NewWhatsAppRepository(db)

// Obtener repositorios existentes (ajusta según tus variables)
// Si ya tienes variables appointmentRepo y patientRepo, úsalas directamente
apptRepo := appointment_repo.NewAppointmentRepository(db)
patRepo := patient_repo.NewPatientRepository(db)

// Inicializar servicio WhatsApp
whatsAppService := whatsapp_service.NewWhatsAppService(
	whatsAppRepo,
	apptRepo,
	patRepo,
)

// Inicializar handler
whatsAppHandler := whatsapp_api.NewWhatsAppHandler(whatsAppService)

// Registrar rutas (ajusta según tu grupo de API)
apiGroup := e.Group("/api") // o usa tu grupo existente
whatsAppHandler.RegisterRoutes(apiGroup)

// Iniciar scheduler (revisa cada hora)
reminderScheduler := scheduler.NewReminderScheduler(whatsAppService, 1*time.Hour)
reminderScheduler.Start()

// Asegurar que el scheduler se detenga cuando cierre el servidor
defer reminderScheduler.Stop()

log.Println("WhatsApp reminder system initialized")
```

### 3. Ejecutar Migraciones

```bash
cd database
psql -U tu_usuario -d tu_base_de_datos -f whatsapp_migrations.sql
```

### 4. Configurar Credenciales

**Opción rápida (SQL directo):**
```sql
UPDATE whatsapp_config SET
  phone_number_id = 'PHONE_NUMBER_ID_DE_META',
  access_token = 'TU_ACCESS_TOKEN_DE_META',
  business_account_id = 'TU_BUSINESS_ACCOUNT_ID',
  is_active = false,  -- Déjalo false hasta que esté todo listo
  reminder_enabled = false
WHERE id = 1;
```

**Opción recomendada (API):**
Usar el endpoint PUT /api/whatsapp/config una vez que el servidor esté corriendo.

## 🔧 Compilación

Debido a que hay algunos métodos que faltan en los repositorios existentes, necesitas:

### Agregar método en AppointmentRepository

En `internal/repository/appointment/repository.go`, agrega a la interfaz:

```go
type AppointmentRepository interface {
	// ... métodos existentes
	ListAppointmentsInDateRange(startTime, endTime time.Time) ([]models.Appointment, error)
}
```

Este método ya existe en el archivo, solo asegúrate de que esté en la interfaz.

## 📝 Ejemplo de Prueba Rápida

Una vez todo configurado:

```bash
# 1. Compilar
cd software-backend
go build -o server cmd/server/main.go

# 2. Correr servidor
./server

# 3. Verificar configuración (con tu JWT token)
curl -H "Authorization: Bearer TU_JWT" http://localhost:8080/api/whatsapp/config

# 4. Actualizar config para activar (ejemplo)
curl -X PUT http://localhost:8080/api/whatsapp/config \
  -H "Authorization: Bearer TU_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number_id": "TU_PHONE_ID",
    "access_token": "TU_TOKEN",
    "is_active": false,
    "reminder_enabled": false
  }'
```

## ⚠️ Notas Importantes

1. **NO actives (`is_active=true`) hasta que:**
   - Hayas configurado correctamente la app en Meta
   - Hayas creado y aprobado la plantilla de mensaje
   - Hayas probado con el número de prueba

2. **El scheduler corre cada hora por defecto.** Puedes cambiarlo a cada 30 min o lo que necesites:
   ```go
   reminderScheduler := scheduler.NewReminderScheduler(whatsAppService, 30*time.Minute)
   ```

3. **Los números de teléfono** en la tabla `patients` deben tener formato internacional:
   - ✅ `+50212345678`
   - ❌ `12345678`

4. **Logs:** El scheduler imprimirá en consola cuando encuentre y envíe recordatorios.

## 🎯 Next Steps

Lee el archivo completo `WHATSAPP_SETUP.md` para configurar la API de Meta, crear la plantilla y activar el sistema.
