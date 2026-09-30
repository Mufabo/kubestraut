#!/usr/bin/env python3
"""Render chapters/<NN-name>/questions.yaml into that chapter's README.md.

The README must contain the markers:
    <!-- QUESTIONS:START -->
    <!-- QUESTIONS:END -->
Everything between them is replaced. Run with --check in CI to fail if the
committed README is out of date.

Question schema (questions.yaml is a list):
  - id: q01
    type: mcq            # mcq | task
    exams: [KCNA, CKAD]  # optional tags
    question: "..."      # (mcq) or prompt: "..." (task)
    choices: ["...", "..."]   # mcq only; 2-5 choices
    answer: B                 # mcq only; letter of the correct choice
    explanation: "..."        # why the answer is right
    solution: "..."           # task only; markdown, may include code blocks
"""
import argparse
import pathlib
import sys

import yaml

START, END = "<!-- QUESTIONS:START -->", "<!-- QUESTIONS:END -->"
LETTERS = "ABCDE"


def render(questions):
    body, answers = [], []
    for n, q in enumerate(questions, 1):
        tags = " ".join(f"`{t}`" for t in q.get("exams", []))
        tags = f" {tags}" if tags else ""
        if q["type"] == "mcq":
            choices = q["choices"]
            assert q["answer"] in LETTERS[: len(choices)], f"{q['id']}: bad answer letter"
            body.append(f"**{n}.**{tags} {q['question'].strip()}\n")
            for i, c in enumerate(choices):
                body.append(f"- **{LETTERS[i]}.** {c}")
            body.append("")
            answers.append(f"**{n}. {q['answer']}.** {q['explanation'].strip()}\n")
        elif q["type"] == "task":
            body.append(f"**{n}. (Task)**{tags} {q['prompt'].strip()}\n")
            answers.append(f"**{n}.**\n\n{q['solution'].strip()}\n")
        else:
            raise ValueError(f"{q['id']}: unknown type {q['type']}")
    out = ["## End-of-chapter questions\n", *body,
           "<details>\n<summary>Answers</summary>\n", *answers, "</details>"]
    return "\n".join(out).rstrip() + "\n"


def process(chapter_dir, check):
    qfile = chapter_dir / "questions.yaml"
    readme = chapter_dir / "README.md"
    if not qfile.exists():
        return True
    text = readme.read_text()
    if START not in text or END not in text:
        print(f"{readme}: missing question markers", file=sys.stderr)
        return False
    head, rest = text.split(START, 1)
    _, tail = rest.split(END, 1)
    questions = yaml.safe_load(qfile.read_text())
    new = f"{head}{START}\n\n{render(questions)}\n{END}{tail}"
    if new == text:
        return True
    if check:
        print(f"{readme}: questions out of date; run tools/render-questions.py", file=sys.stderr)
        return False
    readme.write_text(new)
    print(f"updated {readme}")
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("chapters", nargs="*", type=pathlib.Path)
    args = ap.parse_args()
    root = pathlib.Path(__file__).resolve().parent.parent
    dirs = args.chapters or sorted((root / "chapters").glob("*/"))
    ok = all([process(d, args.check) for d in dirs])
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
