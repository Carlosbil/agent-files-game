---
name: obsidian-markdown
description: Use when Codex needs to create, modify, edit, rewrite, organize, or document any Markdown (.md) file, especially project notes intended to be read in Obsidian. Usar al crear o modificar notas Markdown, documentacion de repositorio, mapas de proyecto, planes, arquitectura, guias, descripciones funcionales o contenido que deba ser claro para lectores no tecnicos.
---

# Obsidian Markdown

## Core Rule

Escribir Markdown para que se lea bien en Obsidian: claro, conciso, bien enlazado y comprensible para una persona no tecnica.

## Workflow

1. Leer notas cercanas antes de editar, especialmente `MAPA_PROYECTO.md`, planes, README y archivos enlazados por la nota objetivo.
2. Conservar el estilo de la nota existente salvo que el usuario pida otro formato.
3. Preferir una nota enfocada por tema. Si una nota crece demasiado, separar por temas y enlazar las notas.
4. Escribir para escaneo rapido: secciones cortas, parrafos breves, bullets directos y ejemplos concretos.
5. Despues de crear o modificar Markdown en este repositorio, seguir las instrucciones del repo para sincronizar con el mirror de Obsidian.

## Obsidian Structure

Para notas de proyecto, preferir esta forma:

```markdown
# Clear note title

Relacionado: [[MAPA_PROYECTO]] - [[OTHER_RELEVANT_NOTE]]

## Resumen

Explicacion breve de que contiene la nota y por que importa.

## Tema principal

Contenido claro y practico.

## Siguientes pasos

- Siguiente accion concreta.
```

Usar wiki links como `[[PLAN_MINIJUEGOS_AI]]` para notas internas. Conservar rutas relativas al repositorio cuando se mencionen archivos para que los enlaces sean estables.

## Writing Style

- Explicar con claridad y concision, tambien para lectores no tecnicos.
- Empezar por la respuesta util y despues anadir detalle.
- Usar espanol claro por defecto en repositorios en espanol.
- Definir terminos tecnicos la primera vez que importen.
- Preferir voz activa y verbos concretos.
- Usar titulos descriptivos, no ingeniosos.
- Usar listas cuando mejoren la lectura rapida.
- Evitar parrafos largos, relleno, afirmaciones vagas y jerga sin explicar.
- No anadir frontmatter salvo que las notas cercanas ya lo usen o el formato del archivo lo requiera.

## Editing Existing Notes

- Mantener enlaces, titulos y contexto existente que sigan siendo utiles.
- Mejorar la estructura sin cambiar el significado original.
- Convertir texto denso en secciones, bullets, tablas o resumenes cortos cuando eso mejore la lectura.
- Si se agrega una nota que pertenece al grafo del proyecto, actualizar `MAPA_PROYECTO.md` o el indice relevante.
- Si la nota tiene un formato obligatorio como `SKILL.md`, preservar esa estructura exactamente y aplicar dentro las reglas de claridad.

## Quality Check

Antes de terminar, comprobar:

- El titulo dice que es la nota.
- La primera seccion explica el punto rapidamente.
- Una persona no tecnica puede seguir la idea principal.
- Los enlaces son utiles y funcionan bien en Obsidian.
- Las rutas de archivos son estables y relativas al repositorio.
- La nota no duplica contenido sin necesidad.
- Se cumplieron los requisitos de sincronizacion Markdown del repositorio.
