###############################################################################
#
# SPAC system for mono species system
#
###############################################################################
"""
    mutable struct SPACMono{FT}

Struct that mono species SPAC system.

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef mutable struct SPACMono{FT<:AbstractFloat}
    "Soil layers bounds `[m]`"
    soil_bounds::Array{FT,1} = FT[0,-0.1,-0.2,-0.3,-0.5,-0.8,-1.2,-2.0]
    "Air layers bounds `[m]`"
    air_bounds ::Array{FT,1} = collect(FT,0:1:20)

    "Root depth `[m]`"
    z_root  ::FT = FT(-1)
    "Canopy maximal height `[m]`"
    z_canopy::FT = FT(10)

    "Plant hydraulic system"
    plant_hs::AbstractPlantHS{FT} = create_grass_like_hs(z_root, z_canopy, soil_bounds, air_bounds)
    "Number of canopy layers"
    n_canopy::Int = length(plant_hs.canopy_index_in_air)
    "Number of root layers"
    n_root  ::Int = length(plant_hs.root_index_in_soil)
    "Plant photosynthesis systems"
    plant_ps::Array{CanopyLayer{FT},1} = [CanopyLayer{FT}() for i in 1:n_canopy]
    "Basal area `[m²]`"
    ba::FT = sum( [plant_hs.roots[i].area for i in 1:n_root] )
    "Ground area `[m²]`"
    ga::FT = ba * 500
    "Leaf area `[m²]`"
    la::FT = sum( plant_hs.leaves[i].area for i in 1:n_canopy )

    # Surrounding AirLayer
    "Air layers"
    envirs::Array{AirLayer{FT},1} = [AirLayer{FT}() for i in 1:n_canopy]

    # Soil layers information
    # TODO bridge Soil module later
    "Maximal soil water content"
    mswc  ::Array{FT,1} = [plant_hs.roots[i].sh.Θs for i in 1:n_root]
    "Current soil water content"
    swc   ::Array{FT,1} = [plant_hs.roots[i].sh.Θs for i in 1:n_root]
    "Array of soil matric potential `[MPa]`"
    p_soil::Array{FT,1} = FT[0 for i in 1:n_root]
    "Maximal soil depth `[m]`"
    h_soil::FT = abs(z_root)

    # geography related
    "Latitude `[°]`"
    latitude ::FT = 30
    "Longitude `[°]`"
    longitude::FT = 116
    "Elevation `[m]`"
    elevation::FT = 0

    # photosynthesis mode and stomatal model scheme
    "Photosynthesis parameter set"
    photo_set::AbstractPhotoModelParaSet{FT} = C3CLM(FT)
    "Stomatal behavior scheme"
    stomata_model::AbstractStomatalModel{FT} = ESMBallBerry{FT}()

    # For CanopyRadiation module
    "Solar angle container"
    angles::SolarAngles{FT} = SolarAngles{FT}()
    "Canopy4RT container"
    canopy_rt::Canopy4RT{FT} = create_canopy_rt(FT, nLayer=n_canopy, LAI=la/ga)
    "Wave length container"
    wl_set::WaveLengths{FT} = create_wave_length(FT)
    "RT dimensions"
    rt_dim::CanopyLayers.RTDimensions = create_rt_dims(canopy_rt, wl_set);
    "CanopyRads container"
    can_rad::CanopyRads{FT} = create_canopy_rads(FT, rt_dim)
    "CanopyOpticals container"
    can_opt::CanopyOpticals{FT} = create_canopy_opticals(FT, rt_dim)
    "Array of LeafBios container"
    leaves_rt::Array{LeafBios{FT},1} = [create_leaf_bios(FT, rt_dim) for i in 1:n_canopy]
    "SoilOpticals container"
    soil_opt::SoilOpticals{FT} = create_soil_opticals(wl_set)
    "Incoming radiation container"
    in_rad::IncomingRadiation{FT} = create_incoming_radiation(wl_set)
    "RT container"
    rt_con::RTContainer{FT} = create_rt_container(FT, rt_dim)
end
