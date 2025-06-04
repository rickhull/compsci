# Rational Prime Calendar

*A rational basis for a calendar based on 61 day periods*

The Gregorian calendar is a 400-year-old hack job.
February's weird.
July-August breaks the pattern,
and no one can remember which months have 31 days.
But there's a better way, hidden in prime factorization.

## Considerations

* Solar day (roughly 24 hours for the earth to rotate)
* Solar year (365.2425 solar days for the earth to orbit the sun)
* Lunar cycle (29.53 days for 8 distinct moon phases, roughly 12x annually)

It's impossible to coordinate or synchronize these 3 cycles perfectly.
But we can devise a system to accommodate them and minimize tradeoffs.
We also want to consider historical calendars, particularly the current
Gregorian calendar and less so the prior Julian calendar.

## Approach

If a solar year is considered to be 366 days, this factors to 61 * 3 * 2,
which naturally suggests (6) 61-day periods, or alternately (61) 6-day periods.
Perhaps we should have 6 day weeks, but that will be for another proposal.

We can split each 61-day period into alternating months of 30 and 31 days,
in either order.  This provides some alignment with the lunar cycle as well
as traditional calendars.

### The Prime Insight

* **61 is prime**; indivisible, mathematically fundamental
* Each of 6 periods of 61 days can be split into **pairs of months, 30 + 31**
* 12 months matches the **lunar cycle** of roughly 30 days
* 12 months allows clean **divisibility by 4** (seasons, business quarters)
* 12 months matches **tradition**
* **Resist entropy**: a regular pattern of pairs in a predictable order

### Leap Year

We can retain the Gregorian approach to leap years, which solves the problem
of accounting for the remaining 0.2425 days in a solar year as years go by.
We'll pick one month out of twelve that will have an extra day roughly every
4 years.  If 366 days is our starting basis, then the leap month will have
a one-day deficit in most years.

## Specifics

For explication, a leap year is considered the base case, and a "normal year"
is handled specially, in some sense, even though leap years are less frequent.

### Base Case (Leap Year)

* Always alternate 30-31

| Month | Length |
| --- | -- |
| Jan | 30 |
| Feb | 31 |
| Mar | 30 |
| Apr | 31 |
| May | 30 |
| Jun | 31 |
| Jul | 30 |
| Aug | 31 |
| Sep | 30 |
| Oct | 31 |
| Nov | 30 |
| Dec | 31 |

* August through December retain their traditional lengths
* Halloween, Oct 31
* New Year's Eve, Dec 31

### Normal Year

* February has a day removed

| Month | Length |
| ----- | ------ |
| Jan | 30 |
| Feb | 30 |
| Mar | 30 |
| Apr | 31 |
| May | 30 |
| Jun | 31 |
| Jul | 30 |
| Aug | 31 |
| Sep | 30 |
| Oct | 31 |
| Nov | 30 |
| Dec | 31 |

* Retain all base case benefits
* February continues as the traditional leap month
* Start the year with 30-30-30 and alternate after that

## Review

### Compared to Gregorian

* Most February weirdness is gone
* Gregorian July-August flip
  - Gregorian starts big-small, pairwise
  - August is due to be small but is big
  - Pattern is small-big after that
  - Pairwise: 3x big-small, 1x big-big, 2x small-big
* Rational Prime maintains 30-31 throughout
* August through December are identical to Gregorian month lengths
* January through July mismatch the Gregorian pattern

#### Days Per Month

| Month | Gregorian | Rational Prime |
| ----- | --------- | -------------- |
| Jan   | 31        | 30             |
| Feb   | 29/29     | 30/31          |
| Mar   | 31        | 30             |
| Apr   | 30        | 31             |
| May   | 31        | 30             |
| Jun   | 30        | 31             |
| Jul   | 31        | 30             |
| Aug   | 31        | 31             |
| Sep   | 30        | 30             |
| Oct   | 31        | 31             |
| Nov   | 30        | 30             |
| Dec   | 31        | 31             |
| Total | 365/366   | 365/366        |

### Why This Matters

* Predictable patterns (no more "30 days hath September" mnemonics)
* Business quarters are equalized
* Cultural continuity (Halloween, New Year's Eve preserved)
* Mathematical elegance

### What Changes, What Stays

Preserved from Gregorian calendar:

* 12 month structure
* Months of alternating 30 and 31 lengths
* August-December lengths (dates like Halloween and New Year's Eve)
* Leap year frequency and concept
* February as the leap month

Fixed from Gregorian calendar:

* February: awkward 28/29 becomes rational 30/31
* July-August 31-31 pattern reversal becomes logical 30-31 within pattern
* Unpredictable patterns become clean alternation

### Cultural Considerations

This proposal is deliberately intended as a replacement for the Gregorian
calendar, primarily within the Western cultural tradition.
Other cultural traditions or calendars are welcomed yet will probably be
considered out of scope.

### Implementation and Adoption Challenges

This proposal is not intended to address local or global adoption.
The intention is merely to lay out a more desirable scheme than the status quo.
Adoption will have both costs and benefits.
