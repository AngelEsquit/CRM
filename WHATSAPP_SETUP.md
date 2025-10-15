# WhatsApp Reminder System - Configuración e Implementación

## 📋 Resumen

Sistema completo de recordatorios automáticos por WhatsApp para citas médicas, integrado con WhatsApp Business Cloud API.

## ✅ Estado de Implementación

### Completado

- ✅ Modelos de datos (`whatsapp_config.go`)
- ✅ Migraciones de base de datos (`whatsapp_migrations.sql`)
- ✅ Cliente de WhatsApp API (`whatsapp/client.go`)
- ✅ Repositorio para gestión de datos (`repository/whatsapp_repository.go`)
- ✅ Servicio de lógica de negocio (`service/whatsapp_service.go`)
- ✅ Handler/API endpoints (`api/whatsapp_handler.go`)
- ✅ Scheduler para envíos automáticos (`scheduler/reminder_scheduler.go`)

### Pendiente (para integrar en main.go)

- ⏳ Integrar handler y scheduler en el servidor principal
- ⏳ Configurar la API de WhatsApp Business en Meta
- ⏳ Crear y aprobar plantilla de mensajes

---

## 🚀 Paso 1: Ejecutar Migraciones de Base de Datos

```bash
cd /home/javier-espana/Escritorio/CRM/database
psql -U tu_usuario -d tu_base_de_datos -f whatsapp_migrations.sql
```

Esto creará:
- Tabla `whatsapp_config` (configuración de API)
- Tabla `whatsapp_notifications` (tracking de mensajes enviados)
- Tabla `whatsapp_webhook_logs` (logs de webhooks)

---

## 🔧 Paso 2: Configurar WhatsApp Business Cloud API

### 2.1 Crear App en Meta Developers

1. Ve a https://developers.facebook.com
2. Crea una aplicación → tipo "Business"
3. Activa el producto **WhatsApp**
4. Anota:
   - `Phone Number ID` (ID del número de teléfono)
   - `Access Token` (token de acceso)
   - `Business Account ID` (ID de cuenta de negocio)

### 2.2 Crear Plantilla de Mensaje

En el **WhatsApp Manager** (https://business.facebook.com/wa/manage), crea una plantilla:

**Nombre de la plantilla:** `recordatorio_cita`
**Categoría:** `utility`
**Idioma:** `es` (Español)

**Contenido del mensaje:**
```
Hola {{1}}, te recordamos que tienes una cita médica el {{2}} a las {{3}}.
Por favor confirma si podrás asistir.
```

**Variables:**
1. `{{1}}`: Nombre del paciente
2. `{{2}}`: Fecha de la cita (ej: 15/10/2025)
3. `{{3}}`: Hora de la cita (ej: 10:30)

**⚠️ Importante:** Espera a que Meta apruebe la plantilla (puede tardar minutos u horas).

### 2.3 Configurar Webhook (Opcional, pero Recomendado)

1. En tu app de Meta Developers, ve a **WhatsApp** → **Configuration**
2. En la sección **Webhooks**, configura:
   - **Callback URL:** `https://tu-dominio.com/api/whatsapp/webhook`
   - **Verify Token:** (Genera un token aleatorio, ej: `tu_token_secreto_123`)
3. Suscríbete a los eventos:
   - `messages` (mensajes entrantes)
   - `message_status` (estado de mensajes: enviado, entregado, leído)

---

## ⚙️ Paso 3: Configurar el Sistema

### 3.1 Actualizar Configuración en Base de Datos

Puedes configurar directamente en la BD o usar el endpoint API (recomendado).

**Opción A: Vía SQL**
```sql
UPDATE whatsapp_config SET
  phone_number_id = 'TU_PHONE_NUMBER_ID',
  access_token = 'TU_ACCESS_TOKEN',
  business_account_id = 'TU_BUSINESS_ACCOUNT_ID',
  webhook_verify_token = 'tu_token_secreto_123',
  is_active = true,
  reminder_enabled = true,
  reminder_3_days_before = true,
  reminder_1_day_before = true,
  reminder_2_hours_before = false,
  template_name_reminder = 'recordatorio_cita',
  template_lang_code = 'es'
WHERE id = 1;
```

**Opción B: Vía API** (Recomendado - una vez integrado)
```bash
curl -X PUT http://localhost:8080/api/whatsapp/config \
  -H "Authorization: Bearer TU_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number_id": "TU_PHONE_NUMBER_ID",
    "access_token": "TU_ACCESS_TOKEN",
    "business_account_id": "TU_BUSINESS_ACCOUNT_ID",
    "webhook_verify_token": "tu_token_secreto_123",
    "is_active": true,
    "reminder_enabled": true,
    "reminder_3_days_before": true,
    "reminder_1_day_before": true,
    "reminder_2_hours_before": false,
    "template_name_reminder": "recordatorio_cita",
    "template_lang_code": "es"
  }'
```

### 3.2 Verificar Configuración

```bash
curl -X GET http://localhost:8080/api/whatsapp/config \
  -H "Authorization: Bearer TU_JWT_TOKEN"
```

---

## 🔌 Paso 4: Integrar en main.go

Necesitas agregar el handler y el scheduler al servidor principal.

**En `cmd/server/main.go`**, agrega lo siguiente:

```go
import (
	// ... tus imports existentes
	"time"
	"software-backend/internal/api"
	"software-backend/internal/repository"
	"software-backend/internal/service"
	"software-backend/internal/scheduler"
)

func main() {
	// ... tu código existente de configuración de DB, Echo, etc.

	// Inicializar repositorios
	whatsAppRepo := repository.NewWhatsAppRepository(db)
	
	// Inicializar servicio
	whatsAppService := service.NewWhatsAppService(
		whatsAppRepo,
		appointmentRepo, // Tu repositorio de citas existente
		patientRepo,     // Tu repositorio de pacientes existente
	)

	// Inicializar handler
	whatsAppHandler := api.NewWhatsAppHandler(whatsAppService)

	// Registrar rutas
	apiGroup := e.Group("/api")
	whatsAppHandler.RegisterRoutes(apiGroup)

	// Iniciar scheduler (revisa cada 1 hora)
	reminderScheduler := scheduler.NewReminderScheduler(whatsAppService, 1*time.Hour)
	reminderScheduler.Start()

	// Asegurar que el scheduler se detenga al cerrar el servidor
	defer reminderScheduler.Stop()

	// ... resto de tu código (e.Start, etc.)
}
```

---

## 📝 Endpoints de API

### 1. Obtener Configuración

```bash
GET /api/whatsapp/config
Authorization: Bearer {JWT_TOKEN}
```

**Respuesta:**
```json
{
  "id": 1,
  "phone_number_id": "1234567890",
  "business_account_id": "9876543210",
  "is_active": true,
  "reminder_enabled": true,
  "reminder_3_days_before": true,
  "reminder_1_day_before": true,
  "reminder_2_hours_before": false,
  "template_name_reminder": "recordatorio_cita",
  "template_lang_code": "es"
}
```

### 2. Actualizar Configuración

```bash
PUT /api/whatsapp/config
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json

{
  "is_active": true,
  "reminder_enabled": true,
  "reminder_3_days_before": true,
  "reminder_1_day_before": true
}
```

### 3. Webhook de Verificación (Usado por Meta)

```bash
GET /api/whatsapp/webhook?hub.mode=subscribe&hub.verify_token=tu_token&hub.challenge=CHALLENGE_STRING
```

### 4. Webhook de Eventos (Usado por Meta)

```bash
POST /api/whatsapp/webhook
Content-Type: application/json

{...payload de WhatsApp...}
```

---

## 🕒 Funcionamiento del Sistema

### Scheduler

El scheduler se ejecuta cada hora (configurable) y:
1. Busca citas programadas dentro de ventanas de tiempo específicas:
   - **3 días antes:** Citas entre 72-73 horas desde ahora
   - **1 día antes:** Citas entre 24-25 horas desde ahora
   - **2 horas antes:** Citas entre 2-3 horas desde ahora
2. Para cada cita encontrada:
   - Verifica que no se haya enviado ya ese tipo de recordatorio
   - Obtiene los datos del paciente
   - Envía el mensaje por WhatsApp
   - Guarda el registro en `whatsapp_notifications`

### Estados de Notificación

- `pending`: Creado, esperando envío
- `sent`: Enviado exitosamente a WhatsApp
- `delivered`: Entregado al dispositivo del paciente
- `read`: Leído por el paciente
- `failed`: Error al enviar

---

## 🧪 Pruebas

### Prueba Manual del Envío

Puedes probar manualmente el envío creando una notificación:

```sql
-- Crear una cita de prueba (ajusta los IDs según tu BD)
INSERT INTO appointments (patient_id, name, start, duration)
VALUES (1, 'Consulta de prueba', NOW() + INTERVAL '25 hours', INTERVAL '30 minutes');

-- El scheduler detectará esta cita automáticamente en la próxima ejecución
```

**O usar el servicio directamente en tu código:**
```go
// En algún handler de prueba
appointment, _ := appointmentRepo.GetAppointmentByID(1)
patient, _ := patientRepo.GetPatientByID(1)
err := whatsAppService.SendReminder(ctx, appointment, patient, "1_day")
```

### Verificar Logs

```bash
# Ver logs del servidor
tail -f tu_archivo_de_logs.log

# Ver notificaciones en BD
SELECT * FROM whatsapp_notifications ORDER BY created_at DESC LIMIT 10;

# Ver webhooks recibidos
SELECT * FROM whatsapp_webhook_logs ORDER BY created_at DESC LIMIT 10;
```

---

## 🔒 Seguridad

### Tokens Sensibles

- ✅ El `access_token` nunca se expone en respuestas de API
- ✅ El `webhook_verify_token` tampoco se expone
- ✅ Solo usuarios autenticados pueden acceder a `/api/whatsapp/config`

### Webhooks

- ✅ Los webhooks son verificados con el `verify_token` antes de procesarse
- ✅ Siempre se devuelve HTTP 200 a Meta para confirmar recepción

---

## 📊 Monitoreo

### Métricas Importantes

Puedes agregar un endpoint para ver estadísticas:

```sql
-- Total de notificaciones por estado
SELECT status, COUNT(*) FROM whatsapp_notifications GROUP BY status;

-- Notificaciones fallidas recientes
SELECT * FROM whatsapp_notifications 
WHERE status = 'failed' 
ORDER BY sent_at DESC LIMIT 20;

-- Tasa de lectura
SELECT 
  COUNT(CASE WHEN read_at IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) as read_rate
FROM whatsapp_notifications
WHERE status IN ('sent', 'delivered', 'read');
```

---

## 🐛 Solución de Problemas

### Problema: No se envían recordatorios

**Verificar:**
1. ¿Está activo el sistema?
   ```sql
   SELECT is_active, reminder_enabled FROM whatsapp_config;
   ```
2. ¿El scheduler está corriendo? (Ver logs del servidor)
3. ¿Las citas tienen pacientes con números de teléfono?
   ```sql
   SELECT a.id, p.name, p.phone FROM appointments a 
   JOIN patients p ON a.patient_id = p.id 
   WHERE a.start > NOW();
   ```

### Problema: Mensajes fallan

**Causas comunes:**
- Token de acceso inválido o expirado
- Plantilla no aprobada por Meta
- Número de teléfono inválido (debe incluir código de país con +)
- Límite de mensajes alcanzado (cuentas no verificadas)

**Ver errores:**
```sql
SELECT * FROM whatsapp_notifications 
WHERE status = 'failed' 
ORDER BY sent_at DESC;
```

### Problema: Webhooks no se reciben

1. Verifica que la URL sea accesible públicamente (HTTPS)
2. Verifica que el `verify_token` coincida
3. Revisa logs de tu servidor

---

## 📚 Referencias

- [WhatsApp Business Platform Documentation](https://developers.facebook.com/docs/whatsapp)
- [Cloud API Reference](https://developers.facebook.com/docs/whatsapp/cloud-api)
- [Message Templates](https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates)
- [Webhooks](https://developers.facebook.com/docs/graph-api/webhooks)

---

## ✨ Próximas Mejoras

- [ ] Agregar soporte para mensajes personalizados (no solo plantillas)
- [ ] Dashboard en frontend para ver estadísticas
- [ ] Configuración de horarios permitidos para envío
- [ ] Reintentos automáticos con backoff exponencial
- [ ] Soporte para múltiples idiomas
- [ ] Confirmación de cita via WhatsApp
- [ ] Notificaciones push a administradores cuando hay fallos

---

## 👤 Contacto

Si tienes dudas sobre la implementación, revisa el código o contacta al equipo de desarrollo.
