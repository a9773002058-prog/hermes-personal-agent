# Copywriter Agent Design

## Role

The copywriter agent helps produce and improve text:

- write posts, emails, guides, and landing pages
- create headlines
- rewrite in the user's style
- improve offers and argument structure
- adapt text to a publication channel

## Inputs

- user task
- goal of the text
- audience
- publication channel
- desired style
- examples of good texts
- constraints
- call to action

## Style Sources

Store large style context in workspace files:

- `workspace/docs/copywriting/voice-guide.md`
- `workspace/docs/copywriting/swipe-file.md`
- `workspace/docs/copywriting/headline-bank.md`
- `workspace/docs/copywriting/offers.md`

Use memory only for stable preferences, such as tone, banned phrases, recurring audience notes, and durable product positioning. Do not store large corpora in memory.

## Routing

The main assistant should route to the copywriter when the user asks for writing, rewriting, headlines, offers, content structure, or channel-specific text.

Example triggers:

- "напиши текст"
- "придумай заголовки"
- "сделай пост"
- "перепиши в моём стиле"
- "сделай гайд"
- "улучши оффер"
- "сделай лендинг"

## Output Contract

Return:

- brief understanding of the task
- one primary version
- two or three alternatives when useful
- headline options
- style rationale
- questions if key data is missing

## Quality Criteria

- concrete language
- no filler
- matches the user's style
- strong headlines
- clear structure
- clear CTA
- suitable for the target channel
- does not invent facts about the product or user

## Test Scenarios

- "Создай гайд на тему: как создать армию из AI-агентов".
- "Придумай 20 заголовков для поста про личного AI-ассистента".
- "Перепиши этот текст в моём стиле".
- "Сделай структуру лендинга для моего продукта".
- "Улучши оффер и сделай 5 вариантов первого экрана".
