module OverviewSortTest exposing (suite)

import Expect
import Model exposing (Sort(..))
import Overview exposing (Row, sortByConversion, sortRows)
import Test exposing (..)


suite : Test
suite =
    describe "Sorting overview tables"
        [ testMaybeList
        , testSortRows
        ]


orderList : Sort -> List a -> List a
orderList sort =
    case sort of
        ASC ->
            List.reverse

        _ ->
            identity


compareMaybe : Maybe comparable -> Maybe comparable -> Order
compareMaybe m1 m2 =
    case ( m1, m2 ) of
        ( Nothing, Nothing ) ->
            EQ

        ( Just _, Nothing ) ->
            LT

        ( Nothing, Just _ ) ->
            GT

        ( Just n1, Just n2 ) ->
            compare n1 n2


testSortRows : Test
testSortRows =
    describe "Sorting table rows"
        [ test "Sort a list of rows by conversion field" <|
            \_ ->
                let
                    input =
                        [ Row "myr" 41.5 (Just 8.71)
                        , Row "thb" 1864.0 (Just 50.22)
                        , Row "foo" 60.0 Nothing
                        , Row "usd" 5.25 (Just 4.41)
                        , Row "bar" 2660.35 Nothing
                        ]

                    sorted =
                        [ Row "usd" 5.25 (Just 4.41)
                        , Row "myr" 41.5 (Just 8.71)
                        , Row "thb" 1864.0 (Just 50.22)
                        , Row "foo" 60.0 Nothing
                        , Row "bar" 2660.35 Nothing
                        ]
                in
                Expect.equal (sortByConversion input) sorted
        ]


testMaybeList : Test
testMaybeList =
    describe "Sorting lists containing Maybe types"
        [ test "Sort a list of Maybe Int" <|
            \_ ->
                let
                    input =
                        [ Just 4
                        , Nothing
                        , Just 3
                        , Just 1
                        , Nothing
                        , Just 2
                        ]

                    sorted =
                        [ Just 1
                        , Just 2
                        , Just 3
                        , Just 4
                        , Nothing
                        , Nothing
                        ]
                in
                Expect.equal (List.sortWith compareMaybe input) sorted
        , test "Sort a list of Maybe String" <|
            \_ ->
                let
                    input =
                        [ Just "d"
                        , Just "a"
                        , Nothing
                        , Just "c"
                        , Nothing
                        , Just "b"
                        ]

                    sorted =
                        [ Just "a"
                        , Just "b"
                        , Just "c"
                        , Just "d"
                        , Nothing
                        , Nothing
                        ]
                in
                Expect.equal (List.sortWith compareMaybe input) sorted
        , test "Sort a list of records with a field containing Maybe" <|
            \_ ->
                let
                    input =
                        [ { foo = 1, bar = Just 2 }
                        , { foo = 4, bar = Just 3 }
                        , { foo = 2, bar = Nothing }
                        , { foo = 3, bar = Just 1 }
                        ]

                    sorted =
                        [ { foo = 3, bar = Just 1 }
                        , { foo = 1, bar = Just 2 }
                        , { foo = 4, bar = Just 3 }
                        , { foo = 2, bar = Nothing }
                        ]

                    sortList =
                        List.sortWith (\a b -> compareMaybe a.bar b.bar)
                in
                Expect.equal (sortList input) sorted
        ]
