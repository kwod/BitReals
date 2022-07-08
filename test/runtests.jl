using BitReals
using Test
using Base.MathConstants

@testset "BitReals.jl" begin

    @test !isfinite(BitReal())
    @test iszero(BitReal(()))
    @test isone(BitReal([true]))
    @test Rational(BitReal()) == 1//0
    @test Rational(BitReal("")) == 0//1
    @test Rational(BitReal("1")) == 1//1
    @test Rational(BitReal("0")) == -1//1
    @test Rational(BitReal("10")) == 1//2

    @test Rational(BitReal(nothing)) == 1//0

    @test Rational(BitReal(-1//0)) == 1//0
    @test Rational(BitReal(π), 25) == 355//113
    @test Rational(BitReal(ℯ), 256) == 5497266116765068273202//2022331187006238110159

end;