/*

    How do I get a list of users and groups assigned to the project folder?

 */
SELECT s.name          AS SiteNM,
       permissions.*,
       c.display_name  AS CapabilityNM,
       c.display_order AS CapabilityOrderNBR,
       CASE
           WHEN permission = 1 THEN 'Grant'
           WHEN permission = 2 THEN 'Deny'
           WHEN permission = 3 THEN 'Grant'
           WHEN permission = 4 THEN 'Deny'
           ELSE NULL
           END         AS PermissionDSC
FROM (SELECT p.site_id         AS SiteID,
             N.authorizable_id AS ProjectID,
             P.name            AS ProjectNM,
             'Project'         AS PermissionGroupDSC,
             N.grantee_id      AS GroupID,
             G.name            as GroupNM,
             N.capability_id   AS CapabilityID,
             N.permission
      FROM next_gen_permissions N
               LEFT JOIN groups G ON N.grantee_id = G.id
               LEFT JOIN projects P ON N.authorizable_id = P.id
      WHERE N.grantee_type = 'Group'
        AND N.authorizable_type = 'Project'
        AND P.name is not NULL

      UNION

      SELECT prj.site_id   as SiteID,
             prj.id        AS ProjectID,
             prj.name      as ProjectNM,
             template_type AS PermissionGroupDSC,
             grantee_id    AS GroupID,
             g.name        AS GroupNM,
             capability_id as CapabilityID,
             permission    as PermissionCD
      FROM public.permissions_templates p
               LEFT JOIN public.capabilities c ON p.capability_id = c.id
               LEFT JOIN public.projects prj ON p.container_id = prj.id
               LEFT JOIN groups g ON p.grantee_id = g.id
      WHERE template_type IN ('Workbook', 'Datasource')
        AND grantee_type = 'Group') AS permissions
         LEFT JOIN public.capabilities c ON permissions.CapabilityID = c.id
         LEFT JOIN public.sites s ON SiteID = s.id

ORDER BY ProjectNM, GroupNM, PermissionGroupDSC, c.display_order;