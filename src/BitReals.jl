module BitReals

import Base: iterate, eltype, IteratorSize, show, isinf, isempty, isfinite, zero, iszero, Rational,
    one, isone
using Base: SizeUnknown, IsInfinite
using Base.Iterators: flatten, cycle, take, peel
export BitReal

struct BitReal <: Number
    bits
end

iterate(br::BitReal, bits = br.bits) = peel(bits)
eltype(::Type{BitReal}) = Bool

function show(io::IO, br::BitReal, m = 64)
    if isinf(br)
        print(io, "∞")
    else
        cs = ['|']
        while !isempty(br) & (m > 0)
            bit, br = Iterators.peel(br)
            push!(cs, bit ? '1' : '0')
            m -= 1
        end
        push!(cs, isempty(br) ? '|' : '…')
        join(io, cs)
    end
end

BitReal() = BitReal(nothing)
BitReal(s::String) = BitReal(c=='1' for c ∈ s)

struct Ratio{T}
    a::T
    b::T
end

function iterate(r::Ratio, (a, b) = (r.a, r.b))
    if !(a ≈ b)
        a > b ?
            (true, (a - b, b)) :
            (false, (a, b - a))
    end
end

function eltype(::Type{Ratio})
    Bool
end

function IteratorSize(::Type{Ratio})
    SizeUnknown()
end

BitReal(x::Real) =
    BitReal(
        if isfinite(x)
            flatten(
                if iszero(x)
                    ()
                elseif x < 0
                    (false, Ratio(one(x), -x))
                else
                    (true, Ratio(x, one(x)))
                end)
        end
    )

BitReal(r::Rational) =
    BitReal(
        if isfinite(r)
            flatten(
                if iszero(r)
                    ()
                elseif r < 0
                    (false, Ratio(r.den, -r.num))
                else
                    (true, Ratio(r.num, r.den))
                end)
        end
    )


isinf(br::BitReal) = isnothing(br.bits)
isfinite(br::BitReal) = !isnothing(br.bits)
isempty(br::BitReal) = isempty(br.bits)
iszero(br::BitReal) = isempty(br)
isone(br::BitReal) = Rational(br) == 1//1

zero(::BitReal) = BitReal(())
one(::BitReal) = BitReal((true))

function Rational(br::BitReal, maxbits = 1_000_000)
    isfinite(br) || return big(1//0)
    iszero(br) && return big(0//1)
    sgn, bits = peel(br)
    function bite(lo_hi, bit)
        lo, hi = lo_hi
        mid = lo .+ hi
        bit ? (mid, hi) : (lo, mid)
    end
    bits = take(bits, maxbits)
    lo_hi = big.([0, 1]), big.([1, 0])
    lo, hi = reduce(bite, bits; init = lo_hi)
    r = //((lo .+ hi)...)
    sgn ? r : -inv(r)
end

BitReal(::Irrational{:φ}) = BitReal(flatten((true, cycle((true, false)))))

struct EulerBits end
function Base.iterate(::EulerBits, (k, n) = (0, -1))
    bit = iseven(k)
    if n == 0
        bit, (k + 1, -1)
    elseif n < 0
        bit, (k, 2 * k)
    else
        !bit, (k, n - 1)
    end
end
eltype(::Type{EulerBits}) = Bool
IteratorSize(::Type{EulerBits}) = IsInfinite()

BitReal(::Irrational{:ℯ}) = BitReal(flatten((true, EulerBits())))

struct PiBits end
function Base.iterate(::PiBits, (bit, a, k, A) = (false, 0, 2, BigInt[12 4; 4 1]))
    a == 0 || return bit, (bit, a - 1, k, A)            # yield next bit of koefficient a
    bit = !bit
    while a < 1                                         # no koefficient to yield
        A *= [2k + 1 1; k * k 0]                        # input of next itertation elements
        a1, a2 = A[1] ÷ A[2], A[3] ÷ A[4]               # test for output
        if a1 == a2
            a = a1                                      # output found
            A = [0 1; 1 -a] * A                         # extract output from matrix
        end
        A .÷= gcd(A)
        k += 1
    end
    bit, (bit, a - 1, k, A)                      # start yielding of koefficient a
end
eltype(::Type{PiBits}) = Bool
IteratorSize(::Type{PiBits}) = IsInfinite()

BitReal(::Irrational{:π}) = BitReal(flatten((true, PiBits())))

end
