# Plan: agente automático y gestión para cadena de farmacias

Estado: pendiente de retomar. Basado en una revisión del código (Captain, herramientas personalizadas, canales) y de las respuestas públicas de https://chat.noxutech.com. No se revisó el panel interno de la instalación.

## 1. Ajustes previos (antes de usarlo con clientes)

| Prioridad | Hallazgo | Qué hacer |
|---|---|---|
| Crítico | No hay respaldos; ya se perdió una base de datos una vez. | `pg_dump` diario y copia fuera del servidor. |
| Crítico | `docker-compose.yml` no monta `storage/`: los archivos subidos (adjuntos, fotos de recetas) viven dentro del contenedor y se pierden al recrearlo. No verificado en el servidor real. | Montar un volumen persistente para `storage/`. |
| Alto | El compose usa `chatwoot/chatwoot:latest` con el código montado encima; una actualización de la imagen puede romper los parches. | Fijar la imagen a 4.17.1. |
| Alto | `FORCE_SSL` apagado por defecto; no se vieron HSTS ni CSP en las cabeceras. | `FORCE_SSL=true` y cabeceras en el proxy. |
| Medio | Logo de Chatwoot, imagen rota en la página de asistentes de Captain, el login no parece usar Geist. | Corregir en un PR. |

## 2. Agente automático con un modelo por API

Hallazgos del código:

- Captain solo habla con **un endpoint compatible con OpenAI**, usado para chat y embeddings. No soporta Claude ni Gemini directo; para otro proveedor hace falta un intermediario (LiteLLM u OpenRouter) que enrute ambos.
- Los embeddings están en 768 dimensiones (migración `20260906130000`). Cambiar a un modelo de otra dimensión (OpenAI usa 1536) exige migrar la base de nuevo.
- Con un modelo local chico el asistente falló al usar herramientas (llama3.1:8b). Un modelo grande por API debería mejorar esto.
- Flujo de traspaso: la conversación entra `pending`, Captain responde, y si no puede deja una nota privada con el motivo y la pasa a un agente. Se puede limitar a horario de atención o a ciertos clientes (`response_window`, `audience`).
- Herramientas personalizadas: solo URLs HTTPS con nombre de dominio (no IP ni `localhost`), máximo 15 por cuenta. Hace falta una API pequeña delante del sistema de la farmacia.

Fases:

1. Base: sección 1.
2. Modelo: intermediario, apuntar `CAPTAIN_OPEN_AI_ENDPOINT` y `CAPTAIN_OPEN_AI_MODEL`, probar con conversaciones reales.
3. Conocimiento: horarios, sucursales, servicios, devoluciones, domicilios y FAQs como documentos de Captain.
4. Guardrails: no diagnosticar, no dar dosis ni sustituir fármacos, no interpretar recetas; derivar a humano ante duda clínica o reacción adversa.
5. WhatsApp: conectar el canal; fuera de la ventana de 24 h solo plantillas aprobadas.
6. Herramientas: stock, estado de pedido, sucursal más cercana.
7. Escenarios por intención: disponibilidad, domicilio, recetas, etc.
8. Medir: motivos de traspaso, CSAT, resultados por conversación; ajustar.

Datos de salud: lo que escribe el cliente, incluidas fotos de recetas, se envía al proveedor del modelo. Revisar con asesor legal la normativa de protección de datos y enviar la mínima información posible.

## 3. Funcionalidad para una cadena de farmacias

- Una bandeja y un equipo por sucursal, con reglas de automatización por sucursal y horarios propios (incluye turnos y 24 h).
- Recetas: el cliente envía la foto, Captain la acusa de recibida sin interpretarla, la etiqueta "receta" y la pasa al farmacéutico con prioridad y SLA.
- Farmacovigilancia: etiqueta de reacción adversa que escala de inmediato y avisa por Telegram al responsable.
- Roles: farmacéutico, atención y gerente de sucursal (roles con menú limitado ya implementados).
- Atributos del cliente: sucursal preferida, fidelidad, seguro, consentimiento de contacto.
- Recordatorios de recompra para crónicos con campañas de WhatsApp (solo con consentimiento).
- Panel del ERP dentro de la conversación con el historial de compras (Dashboard Apps).
- Informes por sucursal, CSAT y auditoría.

## Orden recomendado

Sección 1, luego modelo y conocimiento, luego WhatsApp con reglas estrictas y traspaso a humano, y al final recetas y herramientas de stock.
