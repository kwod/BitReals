module ContFrac

import Base: iterate, eltype, IteratorSize, SizeUnknown
export Cf
using Base.Iterators: flatten, peel, take, cycle

struct Cf
    x
end
function iterate(cf::Cf, (num, den) = (cf.x, one(cf.x)))
    if !(den ≈ 0)
        a, r = divrem(num, den)
        Int(a), (den, r)
    end
end
function eltype(::Type{Cf})
    Int
end
function IteratorSize(::Type{Cf})
    SizeUnknown()
end


end