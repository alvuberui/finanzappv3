package com.finanzapp.tags.repository;


import com.finanzapp.tags.repository.entities.TagEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TagRepository extends JpaRepository<TagEntity, Long> {

    boolean existsByNameAndUserEmail(String name, String userEmail);

    List<TagEntity> findByUserEmail(String userEmail);

    Optional<TagEntity> findByIdAndUserEmail(Long id, String userEmail);

    boolean existsByIdAndUserEmail(Long id, String userEmail);

    List<TagEntity> findByUserEmailAndIdIn(String userEmail, List<Long> ids);




}
