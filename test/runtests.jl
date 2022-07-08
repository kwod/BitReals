using BitReals
using Test

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
    @test Rational(BitReal(355//113)) == 355//113
   
end
