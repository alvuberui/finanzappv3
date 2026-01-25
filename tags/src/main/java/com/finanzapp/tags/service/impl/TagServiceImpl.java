package com.finanzapp.tags.service.impl;

import com.finanzapp.tags.repository.TagRepository;
import com.finanzapp.tags.repository.entities.TagEntity;
import com.finanzapp.tags.repository.mapper.TagEntityMapper;
import com.finanzapp.tags.service.TagService;
import com.finanzapp.tags.service.domain.CreateTagRequest;
import com.finanzapp.tags.service.domain.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TagServiceImpl implements TagService {

    private final TagRepository movementRepository;

    private final TagEntityMapper tagEntityMapper;



    @Override
    public Tag createTag(CreateTagRequest createTagRequest, String userEmail) {
        if (!movementRepository.existsByNameAndUserEmail(createTagRequest.getName(), userEmail)) {

            TagEntity savedEntity = movementRepository.save(tagEntityMapper.toEntity(createTagRequest, userEmail));

            return tagEntityMapper.toDomain(savedEntity);
        }
        throw new IllegalArgumentException("La etiqueta con nombre " + createTagRequest.getName() + " ya existe.");
    }

    @Override
    public List<Tag> getTagsByUserEmail(String userEmail) {
        List<TagEntity> tagEntities = movementRepository.findByUserEmail(userEmail);
        return tagEntities.stream()
                .map(tagEntityMapper::toDomain)
                .toList();
    }

    @Override
    public Tag getTagByIdAndUserEmail(Long tagId, String userEmail) {
        TagEntity tagEntity = movementRepository.findByIdAndUserEmail(tagId, userEmail)
                .orElseThrow(() -> new IllegalArgumentException("La etiqueta con id " + tagId + " no existe para el usuario " + userEmail + "."));
        return tagEntityMapper.toDomain(tagEntity);
    }

    @Override
    public Void deleteTag(Long tagId, String userEmail) {
        TagEntity tagEntity = movementRepository.findByIdAndUserEmail(tagId, userEmail)
                .orElseThrow(() -> new IllegalArgumentException("La etiqueta con id " + tagId + " no existe para el usuario " + userEmail + "."));
        movementRepository.delete(tagEntity);
        return null;
    }

    @Override
    public Boolean existsByIdAndUserEmail(Long tagId, String userEmail) {
        return movementRepository.existsByIdAndUserEmail(tagId, userEmail);
    }

    @Override
    public List<Tag> getTagsByIdsAndUserEmail(List<Long> ids, String email) {
        if (ids == null || ids.isEmpty()) return List.of();

        return movementRepository.findByUserEmailAndIdIn(email, ids).stream()
                .map(tagEntityMapper::toDomain)
                .toList();
    }


}
