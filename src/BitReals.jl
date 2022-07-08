module BitReals

import Base: iterate, eltype, IteratorSize, show, isfinite, iszero, Rational, isone


export BitReal, Ratio

struct BitReal <: Number
    iterablebits
end

function Base.iterate(br::BitReal, itr = br.iterablebits)
    Iterators.peel(itr)
end

function Base.eltype(::Type{BitReal})
    Bool
end

function Base.show(io::IO, br::BitReal)
    isfinite(br) ?
        print(io, '|', join((b ? '1' : '0') for b ∈ Iterators.take(br, 64)), '|') :
        print(io, "∞")
end

function BitReal()
    BitReal(nothing)
end

function BitReal(s::String)
    BitReal(c=='1' for c ∈ s)
end

struct Ratio{T}
    a::T
    b::T
end

function Base.iterate(r::Ratio, (a, b) = (r.a, r.b))
    if a ≠ b
        a > b ?
            (true, (a - b, b)) :
            (false, (a, b - a))
    end
end

function Base.eltype(::Type{Ratio})
    Bool
end

function Base.IteratorSize(::Type{Ratio})
    Base.SizeUnknown()
end

function BitReal(r::Rational)
    BitReal(
        if isfinite(r)
            Iterators.flatten(
                if r == 0
                    ()
                elseif r < 0
                    (false, Ratio(r.den, -r.num))
                else
                    (true, Ratio(r.num, r.den))
                end)
        end
    )
end

function BitReal(r::Real)
    BitReal(
        if isfinite(r)
            Iterators.flatten(
                if iszero(r)
                    ()
                elseif r < 0
                    (false, Ratio(one(r), -r))
                else
                    (true, Ratio(r, one(r)))
                end)
        end
    )
end

function Base.isfinite(br::BitReal)
    !isnothing(br.iterablebits)
end

function Base.iszero(br::BitReal)
    isempty(br.iterablebits)
end

function Base.Rational(br::BitReal, maxitr = 64)
    isfinite(br) || return 1//0
    iszero(br) && return 0//1
    sgn, itr = Iterators.peel(br)
    function bite(v, b)
        lo, hi = v
        b ? lo .+= hi : hi .+= lo
        lo, hi
    end
    lo, hi = reduce(bite, Iterators.take(itr, maxitr); init = ([0, 1], [1, 0]))
    r = //((lo .+ hi)...)
    sgn ? r : -inv(r)
end

function Base.isone(br::BitReal)
    Rational(br) == 1//1
end




end
