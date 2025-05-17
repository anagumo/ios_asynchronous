import Foundation

struct TransformationDTOtoDomainMapper {
    func map(_ transformationDTO: TransformationDTO) -> Transformation {
        Transformation(
            identifier: transformationDTO.identifier,
            name: transformationDTO.name,
            info: transformationDTO.info,
            photo: transformationDTO.photo,
            hero: HeroDTOtoDomainMapper().map(transformationDTO.hero)
        )
    }
}
