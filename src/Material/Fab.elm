module Material.Fab
    exposing
        ( -- VIEW
          view
        , Property
        , disabled
        , plain
        , mini
        , ripple
        
          -- TEA
        , Model
        , defaultModel
        , Msg
        , update

          -- RENDER

        , render
        , Store
        , react
        )

{-| The MDC FAB component is a spec-aligned button component adhering to the
Material Design FAB requirements.

## Design & API Documentation

- [Material Design guidelines: Buttons](https://material.io/guidelines/components/buttons-floating-action-button.html)
- [Demo](https://aforemny.github.io/elm-mdc/#fab)

## View
@docs view

## Properties
@docs Property
@docs disabled, plain, mini, ripple

## TEA architecture
@docs Model, defaultModel, Msg, update

## Featured render
@docs render
@docs Store, react
-}

import Html.Attributes exposing (..)
import Html exposing (..)
import Material.Component as Component exposing (Indexed, Index)
import Material.Internal.Fab exposing (Msg(..))
import Material.Internal.Options as Internal
import Material.Msg
import Material.Options as Options exposing (styled, cs, css, when)
import Material.Ripple as Ripple


type alias Model =
    { ripple : Ripple.Model
    }


defaultModel : Model
defaultModel =
    { ripple = Ripple.defaultModel
    }


type alias Msg =
    Material.Internal.Fab.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RippleMsg msg_ ->
            let
                ( ripple, effects ) =
                    Ripple.update msg_ model.ripple
            in
            ( { model | ripple = ripple }, Cmd.map RippleMsg effects )

        NoOp ->
            ( model, Cmd.none )


type alias Config =
    { disabled : Bool
    , ripple : Bool
    }


defaultConfig : Config
defaultConfig =
    { disabled = False
    , ripple = False
    }


type alias Property m =
    Options.Property Config m


disabled : Property m
disabled =
    Internal.option (\config -> { config | disabled = True })


plain : Property m
plain =
    cs "mdc-fab--plain"


mini : Property m
mini =
    cs "mdc-fab--mini"


ripple : Property m
ripple =
    Internal.option (\config -> { config | ripple = True })


view : (Msg -> m) -> Model -> List (Property m) -> String -> Html m
view lift model options icon =
    let
        ({ config } as summary) =
            Internal.collect defaultConfig options

        ( rippleOptions, rippleStyles ) =
            Ripple.view False (RippleMsg >> lift) model.ripple () ()
    in
        Internal.apply summary
            Html.button
            [ cs "mdc-fab"
            , cs "material-icons"
            , Internal.attribute (Html.Attributes.disabled True)
                |> when config.disabled
            , cs "mdc-fab--disabled"
                |> when config.disabled
            , rippleOptions |> when config.ripple
            ]
            []
            ( List.concat
              [ [ styled Html.span
                  [ cs "mdc-fab__icon"
                  ]
                  [ text icon
                  ]
                ]
              ,
                if config.ripple then
                    [ rippleStyles ]
                else
                    []
              ]
            )


type alias Store s =
    { s | fab : Indexed Model }


( get, set ) =
    Component.indexed .fab (\x y -> { y | fab = x }) defaultModel


render :
    (Material.Msg.Msg m -> m)
    -> Index
    -> Store s
    -> List (Property m)
    -> String
    -> Html m
render =
    Component.render get view Material.Msg.FabMsg


react :
    (Material.Msg.Msg m -> m)
    -> Msg
    -> Index
    -> Store s
    -> ( Maybe (Store s), Cmd m )
react =
    Component.react get set Material.Msg.FabMsg (Component.generalise update)
