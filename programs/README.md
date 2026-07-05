# Programs — Scope Tracker

Un archivo por programa de HackerOne en el que participas. Es la fuente de verdad
de qué se puede tocar y qué no — `bugbounty/bugbounty-hunter.sh` lee estos archivos
antes de escanear cualquier target.

## Por qué existe esto

Testear fuera de scope en un programa de HackerOne puede significar:
- Anulación de la recompensa aunque el hallazgo sea real.
- Suspensión o ban del programa (o de la cuenta H1 completa).
- En el peor caso, exposición legal si el activo no pertenece al programa.

Antes de lanzar cualquier escaneo, `dev101x` debe tener el scope documentado acá,
no solo en la memoria o en una pestaña del navegador.

## Uso

```bash
# Crear el archivo de scope de un programa nuevo
../bugbounty/bugbounty-hunter.sh new nombre-programa

# Editar programs/nombre-programa.md:
#   - Completar "In Scope" con los dominios/assets exactos de la política del programa
#   - Completar "Out of Scope" con lo que el programa excluye explícitamente
#   - Copiar las reglas especiales (rate limits, tipos de vuln excluidos, etc.)

# Verificar que un target está cubierto antes de escanear
../bugbounty/bugbounty-hunter.sh scope target.com
```

Cada archivo sigue la plantilla en [`_template.md`](_template.md).

## Regla de oro

Si un target no aparece en ningún archivo de `programs/`, el scanner lo bloquea
por defecto. Usar `FORCE=1` para saltarse el check es una señal de que falta
actualizar el scope — no un flujo normal de trabajo.
