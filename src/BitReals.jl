module BitReals

import Base: iterate, eltype, IteratorSize, show, isfinite, iszero, Rational, isone
using Base: SizeUnknown, IsInfinite
using Base.Iterators: flatten, cycle, take, peel
export BitReal #, Ratio

struct BitReal <: Number
    iterablebits
end

iterate(br::BitReal, itr = br.iterablebits) = peel(itr)
eltype(::Type{BitReal}) = Bool

show(io::IO, br::BitReal) =
    isfinite(br) ?
        print(io, '|', join((b ? '1' : '0') for b ∈ take(br, 64)), '|') :
        print(io, "∞")

BitReal() = BitReal(nothing)
BitReal(s::String) = BitReal(c=='1' for c ∈ s)

struct Ratio{T}
    a::T
    b::T
end

iterate(r::Ratio, (a, b) = (r.a, r.b)) =
    if a ≠ b
        a > b ?
            (true, (a - b, b)) :
            (false, (a, b - a))
    end

eltype(::Type{Ratio}) = Bool
IteratorSize(::Type{Ratio}) = SizeUnknown()

BitReal(r::Rational) =
    BitReal(
        if isfinite(r)
            flatten(
                if r == 0
                    ()
                elseif r < 0
                    (false, Ratio(r.den, -r.num))
                else
                    (true, Ratio(r.num, r.den))
                end)
        end
    )


BitReal(r::Real) =
    BitReal(
        if isfinite(r)
            flatten(
                if iszero(r)
                    ()
                elseif r < 0
                    (false, Ratio(one(r), -r))
                else
                    (true, Ratio(r, one(r)))
                end)
        end
    )


isfinite(br::BitReal) = !isnothing(br.iterablebits)
iszero(br::BitReal) = isempty(br.iterablebits)

function Rational(br::BitReal, maxitr = 64)
    isfinite(br) || return big(1//0)
    iszero(br) && return big(0//1)
    sgn, itr = Iterators.peel(br)
    function bite(v, b)
        lo, hi = v
        b ? lo .+= hi : hi .+= lo
        lo, hi
    end
    itr = Iterators.take(itr, maxitr)
    init = ([big(0), big(1)], [big(1), big(0)])
    lo, hi = reduce(bite, itr; init = init)
    r = //((lo .+ hi)...)
    sgn ? r : -inv(r)
end

isone(br::BitReal) = Rational(br) == 1//1

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
