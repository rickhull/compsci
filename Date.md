# CompSci::Date - A Proleptic Gregorian Calendar

This is a pure-Ruby library that implements a `Date` class for proleptic
Gregorian calendar calculations.
It is written with clarity and correctness in mind, has no external
dependencies, and is suitable for any application that needs a consistent
calendar system across history, without the complexities of the
Julian-Gregorian transition.

## Key Features

*   **Proleptic Gregorian Calendar**:
    The modern Gregorian calendar rules for leap years are extended backward
    to the beginning of the common era.
*   **Epoch**: The calendar begins on `0001-01-01`.
*   **Immutable Date Objects**: Date instances are created using
    `Data.define`, making them lightweight and immutable.
*   **Rich Comparisons**: Includes the `Comparable` module, allowing for
    simple and intuitive date comparisons (`<`, `>`, `==`, `.between?`, etc.).
*   **Date Arithmetic**: Easily add or subtract days from a date, or calculate
    the number of days between two dates.
*   **Day Count Conversion**: Internally, each date is represented by a simple
    integer: the number of days elapsed since the epoch.
*   **Zero Dependencies**: A self-contained, pure-Ruby implementation.

## Installation

Install via Rubygems: `gem install compsci`

```ruby
require 'compsci/date'

pearl_harbor = CompSci::Date.new(1941, 12, 7)
d_day        = CompSci::Date.new(1944, 6, 6)
v_e_day      = CompSci::Date.new(1945, 5, 8) 
v_j_day      = CompSci::Date.new(1945, 8, 14)

d_day.diff(pearl_harbor) # => 912
v_e_day.diff(d_day)      # => 366
v_j_day.diff(v_e_day)    # => 89

pearl_harbor + 24 # => #<data CompSci::Date year=1941, month=12, day=31>
pearl_harbor - 6  # => #<data CompSci::Date year=1941, month=12, day=1>
```

## Usage & API

### Creating a Date

Create a new `Date` instance by providing a `year`, `month`, and `day`.
The month can be an integer, a string, or a symbol.

```ruby
# Create a date with a numeric month
d1 = CompSci::Date.new(year: 2024, month: 7, day: 26)
#=> #<data CompSci::Date year=2024, month=7, day=26>

# Use a string or symbol for the month (case-insensitive)
d2 = CompSci::Date.new(year: 1999, month: 'December', day: 31)
d3 = CompSci::Date.new(year: 1, month: :january, day: 1) # The epoch
```

The constructor validates the date.
Providing an invalid value will raise an error.

```ruby
# Raises CompSci::Date::InvalidDay (2023 is not a leap year)
CompSci::Date.new(year: 2023, month: 2, day: 29)

# Raises CompSci::Date::InvalidMonth
CompSci::Date.new(year: 2023, month: 13, day: 1)

# Raises CompSci::Date::InvalidYear
CompSci::Date.new(year: 0, month: 1, day: 1)
```

### Accessing & Formatting

Date components are available as attributes.
The library provides convenient formatting methods.

```ruby
date = CompSci::Date.new(year: 2025, month: 1, day: 1)

date.year   #=> 2025
date.month  #=> 1
date.day    #=> 1

# Default format is ISO 8601 (YYYY-MM-DD)
date.to_s   #=> "2025-01-01"

# Human-readable long-form name
date.name   #=> "January 1, 2025"
```

### Date Arithmetic

You can perform calculations with dates.
All arithmetic operations return a new `Date` object.

```ruby
date = CompSci::Date.new(year: 2024, month: 2, day: 28)

# Add days
next_day = date + 1
puts next_day  #=> "2024-02-29" (correctly handles leap day)

a_year_later = date + 366
puts a_year_later #=> "2025-02-28"

# Subtract days
yesterday = date - 1
puts yesterday #=> "2024-02-27"

# Get the difference in days between two dates
d1 = CompSci::Date.new(year: 2024, month: 1, day: 1)
d2 = CompSci::Date.new(year: 2025, month: 1, day: 1)

d2.diff(d1)  #=> 366 (2024 is a leap year)
d1.diff(d2)  #=> -366
```

### Comparisons

Because `CompSci::Date` includes the `Comparable` module, you can compare
dates directly.

```ruby
d_start = CompSci::Date.new(year: 2000, month: 1, day: 1)
d_end   = CompSci::Date.new(year: 2000, month: 12, day: 31)
d_check = CompSci::Date.new(year: 2000, month: 6, day: 15)

d_start < d_end      #=> true
d_check == d_start   #=> false

d_check.between?(d_start, d_end) #=> true
```

### Leap Years

Check if a date falls in a leap year or check a year directly.

```ruby
date = CompSci::Date.new(year: 2024, month: 1, day: 1)
date.leap_year?  #=> true

# Also available as a class method
CompSci::Date.leap_year?(2024) #=> true
CompSci::Date.leap_year?(1900) #=> false (divisible by 100 but not 400)
CompSci::Date.leap_year?(2000) #=> true (divisible by 400)
```

### Day Count Conversions

The library's core logic is built on a "day count" —
an integer representing the number of days since the epoch (`0001-01-01`).
You can convert to and from this integer representation.

```ruby
# Get the day count from a Date object
epoch = CompSci::Date.new(year: 1, month: 1, day: 1)
epoch.day_count #=> 1

d = CompSci::Date.new(year: 1, month: 2, day: 1)
d.day_count     #=> 32 (31 days in Jan + 1)

# Create a Date object from a day count
CompSci::Date.from_days(366).to_s     #=> "0002-01-01"
CompSci::Date.from_days(739_265).to_s #=> "2024-12-31"
```

### Utility Class Methods

The `CompSci::Date` class provides several public utility methods for
calendar calculations.

```ruby
# Get the number of days in a specific month and year
CompSci::Date.month_days(month: 2, year: 2024) #=> 29
CompSci::Date.month_days(month: 2, year: 2023) #=> 28

# Get the number of days in a year
CompSci::Date.annual_days(2024) #=> 366
CompSci::Date.annual_days(2023) #=> 365

# Convert between month names and numbers
CompSci::Date.month_name(10)          #=> "October"
CompSci::Date.month_number("October") #=> 10
CompSci::Date.month_number(:october)  #=> 10
```
