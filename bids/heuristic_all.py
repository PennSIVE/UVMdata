import os


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes


def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where

    allowed template fields - follow python string module:

    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """

    t1w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_run-{item:03d}_T1w')
    t2w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_run-{item:03d}_T2w')
    t2star = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_run-{item:03d}_T2star')
    fmap_mag = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_run-{item:03d}_magnitude')
    fmap_phase = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_run-{item:03d}_phasediff')
    info = {t1w: [], t2w: [], t2star: [], fmap_mag: [], fmap_phase: []}

    i = 0
    for s in seqinfo:
        """
        The namedtuple `s` contains the following fields:

        * total_files_till_now
        * example_dcm_file
        * series_id
        * dcm_dir_name
        * unspecified2
        * unspecified3
        * dim1
        * dim2
        * dim3
        * dim4
        * TR
        * TE
        * protocol_name
        * is_motion_corrected
        * is_derived
        * patient_id
        * study_description
        * referring_physician_name
        * series_description
        * image_type
        """

        if '3D_T1_MPRAGE' in s.protocol_name:
            info[t1w].append(s.series_id)
        elif '3D_T2_FLAIR_BrainView' in s.protocol_name:
            info[t2w].append(s.series_id)
        elif 'WIP 3D_T2STAR_segEPI' in s.protocol_name:
            if 'PHASE MAP' in s.image_type:
                info[t2star].append(s.series_id)
            # elif 'MAGNITUDE' in s.image_type:
            #     info[fmap_mag].append(s.series_id)
            # else:
            #     info[t2star].append(s.series_id)
        print(i, s.protocol_name, s.dcm_dir_name, s.example_dcm_file, s.image_type, s.dim1, s.dim2, s.dim3, s.dim4, s.TR, s.TE, sep=',')
        i += 1
        
    return info
