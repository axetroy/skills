---
name: i18n
description: Use this skill whenever generating, modifying, refactoring, or reviewing code involving internationalization (i18n). Ensure all translation calls follow a consistent set of i18n rules.
---

# i18n

All code involving internationalization (i18n) must follow the rules below.

These rules apply regardless of the i18n library or framework being used.

For example:

```ts
i18n(...)
t(...)
$t(...)
i18n.t(...)
i18n.$t(...)
translate(...)
intl(...)
```

or any other project-specific translation function.

---

## Core Rules

### 1. The first argument of a translation function must be a string literal

Regardless of which translation function is used, its first argument must be a string literal written directly in the source code.

Allowed:

```ts
i18n("button.ok");

t("button.ok");

$t("button.ok");

i18n.t("button.ok");

i18n.$t("button.ok");

translate("button.ok");

i18n("OK");
```

---

### 2. Do not construct translation keys dynamically

String concatenation or template literals must not be used to construct translation keys.

❌

```ts
t("button." + name);

i18n(`${prefix}.title`);

$t(namespace + ".title");
```

---

### 3. Do not pass variables as the first argument

Even if a variable contains a constant string, it must not be passed as the first argument of a translation function.

❌

```ts
const key = "button.ok";

t(key);
```

❌

```ts
const key = type === "success" ? "message.success" : "message.error";

i18n(key);
```

❌

```ts
const key = config.title;

$t(key);
```

Instead, write the translation call directly:

```ts
if (type === "success") {
  t("message.success");
} else {
  t("message.error");
}
```

---

### 4. Do not use any expression as the first argument

The first argument must be a string literal. Variables, function calls, conditional expressions, template literals, or any other runtime expressions are not allowed.

❌

```ts
t(foo ? "a" : "b");

t(getKey());

t(key);

t(namespace + ".title");

t(`${prefix}.title`);
```

---

### 5. Use interpolation instead of string concatenation

When inserting dynamic values, use the translation function's interpolation mechanism instead of concatenating translated strings.

Preferred:

```ts
t("welcome", {
  name,
});
```

Instead of:

```ts
t("hello") + name;

t("delete") + fileName;
```

---

## When Modifying Existing Code

When changing code that already uses i18n:

- Preserve the project's existing translation API.
- Do not replace `t()` with `i18n()`.
- Do not replace `i18n()` with `$t()`.
- Do not introduce a different translation function.
- Follow the project's existing style consistently.

At the same time, ensure that:

- The first argument is always a string literal.
- No dynamic key construction is introduced.
- No variables are used as the first argument.
- No runtime-generated translation keys are introduced.

---

## Guidelines

For all translation calls:

1. Preserve the project's existing translation API.
2. The first argument must always be a string literal.
3. Never construct translation keys dynamically.
4. Never pass variables as the first argument.
5. Never use runtime expressions as the first argument.
6. Use interpolation for dynamic values instead of string concatenation.
7. Do not introduce new code that violates these rules.

**Treat any function that returns localized text as a translation function, regardless of its name.**
