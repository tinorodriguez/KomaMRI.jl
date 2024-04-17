@doc raw"""
"""

@with_kw struct PeriodicHeartBeat{T<:Real} <: SimpleMotionType{T}
    circunferential_strain :: T
    radial_strain          :: T
    longitudinal_strain::T = typeof(circunferential_strain)(0.0)
    period::T              = typeof(circunferential_strain)(0.0)
    asymmetry::T           = typeof(circunferential_strain)(0.5)
end

is_composable(motion_type::PeriodicHeartBeat) = true

function displacement_x(
    motion_type::PeriodicHeartBeat{T},
    x::AbstractArray{T},
    y::AbstractArray{T},
    z::AbstractArray{T},
    t::AbstractArray{T},
) where {T<:Real}
    t_unit = unit_time_triangular(t, motion_type.period, motion_type.asymmetry)
    r = sqrt.(x .^ 2 + y .^ 2)
    θ = atan.(y, x)
    Δ_circunferential = motion_type.circunferential_strain * maximum(r)
    Δ_radial = -motion_type.radial_strain * (maximum(r) .- r)
    Δr = t_unit .* (Δ_circunferential .+ Δ_radial)
    # Map negative radius to r=0
    neg = (r .+ Δr) .< 0
    Δr = (.!neg) .* Δr
    Δr .-= neg .* r
    return Δr .* cos.(θ)
end

function displacement_y(
    motion_type::PeriodicHeartBeat{T},
    x::AbstractArray{T},
    y::AbstractArray{T},
    z::AbstractArray{T},
    t::AbstractArray{T},
) where {T<:Real}
    t_unit = unit_time_triangular(t, motion_type.period, motion_type.asymmetry)
    r = sqrt.(x .^ 2 + y .^ 2)
    θ = atan.(y, x)
    Δ_circunferential = motion_type.circunferential_strain * maximum(r)
    Δ_radial = -motion_type.radial_strain * (maximum(r) .- r)
    Δr = t_unit .* (Δ_circunferential .+ Δ_radial)
    # Map negative radius to r=0
    neg = (r .+ Δr) .< 0
    Δr = (.!neg) .* Δr
    Δr .-= neg .* r
    return Δr .* sin.(θ)
end

function displacement_z(
    motion_type::PeriodicHeartBeat{T},
    x::AbstractArray{T},
    y::AbstractArray{T},
    z::AbstractArray{T},
    t::AbstractArray{T},
) where {T<:Real}
    t_unit = unit_time_triangular(t, motion_type.period, motion_type.asymmetry)
    return t_unit .* (z .* motion_type.longitudinal_strain)
end

function time_nodes(motion_type::PeriodicHeartBeat)
    return [0, motion_type.period * motion_type.asymmetry, motion_type.period]
end