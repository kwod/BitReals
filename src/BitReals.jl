module BitReals

import Base: iterate, eltype, IteratorSize

export BitReals

struct BitReal
    iterablebits
end

function Base.iterate(br::BitReal; itr = br.iterablebits)
    isnothing(itr) ? nothing : Iterators.peel(itr)
end

function Base.eltype(::Type{BitReal})
    Bool
end

function Base.IteratorSize(::Type{BitReal})
    Base.SizeUnknown()
end

end
