module Signal
    ( Signal
    , merge, mergeMany
    , map, map2, map3, map4, map5
    , (<~), (~)
    , constant
    , dropRepeats, filter, filterMap, sampleOn
    , foldp
    , Dispatcher, Message
    , dispatcher, send
    ) where

{-| A *signal* is a value that changes over time. For example, we can
think of the mouse position as a pair of numbers that is changing over time,
whenever the user moves the mouse.

    Mouse.position : Signal (Int,Int)

Another signal is the `Element` or `Html` we want to show on screen.

    main : Signal Html

As the `Html` changes, the user sees different things on screen automatically.

Some useful functions for working with time (e.g. setting FPS) and combining
signals and time (e.g. timestamps) can be found in the [`Time`](Time) library.

# Signals
@docs Signal

# Merging
@docs merge, mergeMany

# Mapping
@docs map, map2, map3, map4, map5

# Fancy Mapping
@docs (<~), (~)

# Past-Dependence
@docs foldp

# Filters
@docs filter, filterMap, dropRepeats, sampleOn

# Mailboxes
@docs Mailbox, Address, mailbox, Message, message, forwardTo, send

# Constants
@docs constant

-}


import Basics exposing (fst, snd, not, always)
import Debug
import List
import Maybe exposing (Maybe(Just,Nothing))
import Native.Signal
import Task exposing (Task, succeed, onError)


{-| A value that changes over time. So a `(Signal Int))` is an integer that is
varying as time passes, perhaps representing the current window width of the
browser. Every signal is updated at discrete moments in response to events in
the world.
-}
type Signal a = Signal


{-| Create a signal that never changes. This can be useful if you need
to pass a combination of signals and normal values to a function:

    map3 view Window.dimensions Mouse.position (constant initialModel)
-}
constant : a -> Signal a
constant =
  Native.Signal.constant


{-| Apply a function to a signal.

    mouseIsUp : Signal Bool
    mouseIsUp =
        map not Mouse.isDown

    main : Signal Element
    main =
        map Graphics.Element.show Mouse.position
-}
map : (a -> result) -> Signal a -> Signal result
map =
  Native.Signal.map


{-| Apply a function to the current value of two signals. The function
is reevaluated whenever *either* signal changes. In the following example, we
figure out the `aspectRatio` of the window by combining the current width and
height.

    ratio : Int -> Int -> Float
    ratio width height =
        toFloat width / toFloat height

    aspectRatio : Signal Float
    aspectRatio =
        map2 ratio Window.width Window.height
-}
map2 : (a -> b -> result) -> Signal a -> Signal b -> Signal result
map2 =
  Native.Signal.map2


{-|-}
map3 : (a -> b -> c -> result) -> Signal a -> Signal b -> Signal c -> Signal result
map3 =
  Native.Signal.map3


{-|-}
map4 : (a -> b -> c -> d -> result) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal result
map4 =
  Native.Signal.map4


{-|-}
map5 : (a -> b -> c -> d -> e -> result) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal e -> Signal result
map5 =
  Native.Signal.map5


{-| Create a past-dependent signal. Each update from the incoming signals will
be used to step the state forward. The outgoing signal represents the current
state.

    clickCount : Signal Int
    clickCount =
        foldp (\click total -> total + 1) 0 Mouse.clicks

    timeSoFar : Signal Time
    timeSoFar =
        foldp (+) 0 (fps 40)

So `clickCount` updates on each mouse click, incrementing by one. `timeSoFar`
is the time the program has been running, updated 40 times a second.
-}
foldp : (a -> state -> state) -> state -> Signal a -> Signal state
foldp =
    Native.Signal.foldp


{-| Merge two signals into one. This function is extremely useful for bringing
together lots of different signals to feed into a `foldp`.

    type Update = MouseMove (Int,Int) | TimeDelta Float

    updates : Signal Update
    updates =
        merge
            (map MouseMove Mouse.position)
            (map TimeDelta (fps 40))

If an update comes from either of the incoming signals, it updates the outgoing
signal. If an update comes on both signals at the same time, the left update
wins (i.e., the right update is discarded).
-}
merge : Signal a -> Signal a -> Signal a
merge left right =
    Native.Signal.genericMerge always left right


{-| Merge many signals into one. This is useful when you are merging more than
two signals. When multiple updates come in at the same time, the left-most
update wins, just like with `merge`.

    type Update = MouseMove (Int,Int) | TimeDelta Float | Click

    updates : Signal Update
    updates =
        mergeMany
            [ map MouseMove Mouse.position
            , map TimeDelta (fps 40)
            , map (always Click) Mouse.clicks
            ]
-}
mergeMany : List (Signal a) -> Signal a
mergeMany signalList =
  case List.reverse signalList of
    [] ->
        Debug.crash "mergeMany was given an empty list!"

    signal :: signals ->
        List.foldl merge signal signals


{-| Filter out some updates. The given function decides whether we should
*keep* an update. If no updates ever flow through, we use the default value
provided. The following example only keeps even numbers and has an initial
value of zero.

    numbers : Signal Int

    isEven : Int -> Bool

    evens : Signal Int
    evens =
        filter isEven 0 numbers
-}
filter : (a -> Bool) -> a -> Signal a -> Signal a
filter isOk base signal =
    filterMap (\value -> if isOk value then Just value else Nothing) base signal


{-| Filter out some updates. When the filter function gives back `Just` a
value, we send that value along. When it returns `Nothing` we drop it.
If the initial value of the incoming signal turns into `Nothing`, we use the
default value provided. The following example keeps only strings that can be
read as integers.

    userInput : Signal String

    toInt : String -> Maybe Int

    numbers : Signal Int
    numbers =
        filterMap toInt 0 userInput
-}
filterMap : (a -> Maybe b) -> b -> Signal a -> Signal b
filterMap =
    Native.Signal.filterMap


{-| Drop updates that repeat the current value of the signal.

    numbers : Signal Int

    noDups : Signal Int
    noDups =
        dropRepeats numbers

    --  numbers => 0 0 3 3 5 5 5 4 ...
    --  noDups  => 0   3   5     4 ...

The signal should not be a signal of functions, or a record that contains a
function (you'll get a runtime error since functions cannot be equated).
-}
dropRepeats : Signal a -> Signal a
dropRepeats =
    Native.Signal.dropRepeats


{-| Sample from the second input every time an event occurs on the first input.
For example, `(sampleOn Mouse.clicks (Time.every Time.second))` will give the
approximate time of the latest click. -}
sampleOn : Signal a -> Signal b -> Signal b
sampleOn =
    Native.Signal.sampleOn


{-| An alias for `map`. A prettier way to apply a function to the current value
of a signal.

    main : Signal Html
    main =
      view <~ model

    model : Signal Model

    view : Model -> Html
-}
(<~) : (a -> b) -> Signal a -> Signal b
(<~) =
  map


{-| Intended to be paired with the `(<~)` operator, this makes it possible for
many signals to flow into a function. Think of it as a fancy alias for
`mapN`. For example, the following declarations are equivalent:

    main : Signal Element
    main =
      scene <~ Window.dimensions ~ Mouse.position

    main : Signal Element
    main =
      map2 scene Window.dimensions Mouse.position

You can use this pattern for as many signals as you want by using `(~)` a bunch
of times, so you can go higher than `map5` if you need to.
-}
(~) : Signal (a -> b) -> Signal a -> Signal b
(~) funcs args =
  map2 (\f v -> f v) funcs args


infixl 4 <~
infixl 4 ~



-- MAILBOXES


{-| An Dispatcher is a communication hub, used to receive updates from Tasks and
UI elements. It consists of

  * a signal of values that you can use in your program
  * a `dispatch` function that takes a value and creates a Message (more on that
    in a bit)
-}
type alias Dispatcher a =
    { signal : Signal a
    , dispatch : a -> Message
    }


{-| Create a dispatcher, using the argument as the default value for the new
signal.

Note: Creating new signals is inherently impure, so `dispatcher ()` and
`dispatcher ()` produce two different dispatchers.
-}
dispatcher : a -> Dispatcher a
dispatcher =
  Native.Signal.mailbox
  -- TODO rename

{-| Messages are similar to Tasks, in that the define some effect that can be
run later. However, Tasks can do any effect, but Messages can only cause the
dispatcher to send the Message's value on its signal.

Messages can be sent multiple times. Many UI libraries take Messages to send
whenever something happens (say, a button click). Sometimes they take a function
from the UI state to a message, and you can compose whatever transformations you
need with `dispatch`.

    type Action = Undo | NoOp | ...
    actions = dispatcher NoOp
    undoButton = Graphics.Input.button (actions.dispatch Undo) "Undo"

This creates an undo button that will send the `Undo` action on `actions.signal` whenever the button is clicked.
-}
type Message = Message (Task () ())


{-| If you're not using a UI library, the other way to send a Message is to turn
it into a Task and then send it out a port. If you need the result of a Task
(say, an HTTP response) to be sent back into your program, use this method with
`Task.andThen`.

    dispatcher : Dispatcher Maybe (Result Http.Error String)
    dispatcher = dispatcher Nothing

    port requests : Task () ()
    port requests =
      Http.getString "example.com"
        |> Task.toResult |> Task.map Just
        |> (flip Task.andThen) (send dispatcher.address)

-}
send : Message -> Task () ()
send (Message task) = task
