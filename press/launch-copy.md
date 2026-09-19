# Snaked — launch copy

DRAFT, written 15 Sep by the scheduled session for Lok to edit (claims refreshed 16 Sep). Nothing here has been posted.

Assets in this folder:

| File | What it is |
|---|---|
| `snaked-itch.zip` | The game for itch's upload box: index.html, manifest, sw.js, icons, og.png, favicon (rebuilt 19 Sep from commit c5ec0ba: Esc-only pause, d-pad below the board, race with Breakin's screens, You win/You lost, 30s two-player rematch vote, leaving ends the match, 5s countdown before leaving a finished match, both boards on the race result, race runs until both are out). If index.html changes before posting, rebuild it: `git -C <snaked folder> archive --format=zip -o press/snaked-itch.zip HEAD index.html manifest.json sw.js favicon.svg icon-192.png icon-512.png og.png`. |
| `snaked-run.gif` | 27s loop, 324x568, 1.6 MB. One full winning run by the demo bot at real speed: 30 pieces down to 1, the board filling with stone, the speed-up at the end, then a title card. Lead with this, the speed-up is invisible in a still. |
| `itch-cover.png` | 630x500 itch cover: SNAKED over a real mid-run board. |
| `shot-0-menu.png` | Menu at phone width (2x), re-shot 16 Sep. |
| `shot-1-long-and-slow.png` | 3s in: full length, almost no stone. |
| `shot-2-halfway.png` | Length 14, stone spreading. |
| `shot-3-nearly-gone.png` | Length 4, fast, boxed in by stone. Strongest single image. |

All images are rendered from the real game code (a scratch copy driven frame by frame), not mock-ups. The score tiles in the screenshots are redrawn on top in the game's colours.

Hosted once pushed: `https://brendanlok.github.io/snaked/press/snaked-run.gif`

## One-liner

> Snake, except every apple makes you shorter and faster, and the pieces you shed
> turn to stone. Eat the last apple at length 1 to win.

## Title options

- Snaked — Snake, in reverse: every apple makes you shorter, and what you shed turns to stone
- I made a Snake where you start long and have to eat your way down to nothing
- Snaked: the shorter you get, the faster you go, and the board fills with your own tail

## r/WebGames

**Title:** Snaked — Snake, in reverse: every apple makes you shorter and faster, and what you shed turns to stone

Browser game, no sign-in, no ads, works on phones.

It's Snake with the core rule flipped. You start 30 pieces long, and every apple
makes you shorter. The two tail pieces you lose don't vanish — they turn to
stone where they fell, permanently. The shorter you get, the faster you move.
Eat the last apple at length 1 to win. Edge, stone or your own body ends it, one
life.

The tension is that the two halves of the run are opposite problems. At the start
you're slow with an empty board but so long you can trap yourself. At the end
you're tiny with room to turn, but more than twice as fast and threading a maze
you built. A run is 10 to 35 seconds.

Everyone gets the same apples on the same day, so times are comparable, and there's a daily and all-time leaderboard (no sign-in).

https://brendanlok.itch.io/snaked

## r/playmygame

Their required template, filled in. Check the sidebar rules on AI-assisted games
before posting — the Involvement line is honest about it.

**Title:** [HTML5] Snaked — Snake in reverse: every apple makes you shorter and faster

```
Game Title: Snaked

Playable Link: https://brendanlok.itch.io/snaked

Platform: Browser — desktop and mobile

Description: Snaked is Snake with its one core rule turned around. You start long, 30 pieces coiled at the bottom of the board, and every apple makes you shorter instead of longer. The two pieces you shed don't disappear: they turn permanently to stone where they fell. The shorter you get, the faster you move, and you win by eating the last apple at length 1. Hitting the edge, stone or your own body ends the run. One life.

What makes it tricky is that the start and the end are opposite problems. Early on you're slow and the board is empty, but you're long enough to box yourself in. Near the end you're tiny and have room to turn, but you're more than twice as fast and the board is full of your own stone. Runs take 10 to 35 seconds.

Everyone gets the same apples on the same day, so your time means the same as anyone else's. Finish a run and put your name on today's leaderboard, no sign-in.

Controls: arrow keys or WASD on desktop; on-screen arrow pad or swipe on mobile. Free, no ads, no sign-in, installable to play offline.

Feedback I'd most like: does the reversal click in your first run, and are the last few apples steerable on a phone at that speed?

Free to Play Status:

* [x] Free to play
* [ ] Demo/Key available
* [ ] Paid (Allowed only on Tuesdays with [TT] in the title)

Involvement: Solo project. I came up with the concept and made the design calls — the reversed rule, the fixed speed curve, the controls, what went in and what got cut — and tested it on my own phone. The code was written with Claude, an AI model, working under my direction.
```

## itch.io

**Title:** Snaked

**Tagline (short description, ~140 chars):**

> Snake, in reverse. Every apple makes you shorter and faster, and what you shed
> turns to stone. Eat the last apple at length 1 to win.

**Description:** paste `itch-description.txt`.

**Metadata:**

- Kind of project: HTML5 / playable in browser
- Genre: Action / Arcade
- Tags: `arcade`, `snake`, `singleplayer`, `mobile-friendly`, `no-install`, `minimalist`, `fast-paced`, `short`
- Price: Free
- Upload: `snaked-itch.zip`, tick "This file will be played in the browser". (itch can't embed an outside link, so the GitHub Pages address isn't used here - Breakin went up the same way with `breakin-itch.zip`.)
- Embed options: 420x760, fullscreen button on, mobile friendly on. The itch copy uses the same shared leaderboard and feedback inbox as the test link.
- Cover: `itch-cover.png`; screenshots: `shot-3`, `shot-2`, `shot-1`, `shot-0`; GIF first in the description if itch allows it

## Show HN

Not included. Breakin skipped HN (Lok, 13 Sep); same call for Snaked unless Lok says otherwise.

## Before posting — claims to check

- **Feedback box:** the inbox went live 16 Sep evening (01-inbox.sql run, sends verified),
  so a line like Breakin's "feedback comes straight to me" is now true and can go back in.
- **Leaderboard and installable app:** both shipped 15 Sep and are now mentioned
  (refreshed 16 Sep). The leaderboard table was still empty on 16 Sep, so save one
  real run on your phone before posting to prove it works end to end.
- **Screenshots, GIF and cover are from 15 Sep morning, before the new phone layout**
  (board filling the screen, sound link on the menu; since 19 Sep the d-pad sits below
  the board, never over it). The gameplay shots crop to the board, so they still read fine. `shot-0-menu.png` was re-shot from the live link
  on 16 Sep (sound link, "tap to start", leaderboard panel), but the board in it is
  empty - re-shoot it once a few real runs are on today's board.
- **"Tested it on my own phone":** true only after Thursday's device pass.
- **"More than twice as fast":** 0.16s per move at full length vs 0.06s at length 1
  is 2.7x. Correct as long as the fixed rules don't change.
- **itch link:** `brendanlok.itch.io/snaked` is a guess at the address; the itch page
  doesn't exist yet. Fix the links once it does.
- The GIF and screenshots show a bot playing. Don't caption them as a human run.
