% http://precedings.nature.com/documents/1720/version/2/files/npre20091720-2.pdf

classdef Subject < symphonyui.core.descriptions.SourceDescription
    
    methods
        
        function obj = Subject()
            import symphonyui.core.*;
            
            obj.propertyDescriptors = [ ...
                PropertyDescriptor('genus', '', ...
                'type', PropertyType('char', 'row', {'', 'homo', 'macaca', 'mus', 'ovis', 'rattus'}), ...
                'description', 'The genus classification of the study subject according to the NCBI taxonomy classification.'), ...
                PropertyDescriptor('species', '', ...
                'description', 'The species classification of the study subject according to the NCBI taxonomy classification.'), ...
                PropertyDescriptor('strain', '', ...
                'description', 'The strain, genetic variant classification of the study subject, if appropriate.'), ...
                PropertyDescriptor('cellLine', '', ...
                'description', 'The identifier for the immortalised cell line, if appropriate.'), ...
                PropertyDescriptor('geneticCharacteristics', '', ...
                'description', 'The genotype of the study stubject. Genetics characteristics include polymorphisms, disease alleles and haplotypes.'), ...
                PropertyDescriptor('geneticVariation', '', ...
                'description', 'The genetic modification introduced in addition to strain, if appropriate.'), ...
                PropertyDescriptor('diseaseState', '', ...
                'description', 'The name of the pathology diagnosed in the subject. The disease state is �normal� if no disease state has been diagnosed.'), ...
                PropertyDescriptor('clinicalInformation', '', ...
                'description', 'A link, summary or reference to additional clinical information, if appropriate.'), ...
                PropertyDescriptor('sex', '', ...
                'type', PropertyType('char', 'row', {'', 'male', 'female', 'hermaphrodite'}), ...
                'description', 'The sex of the subject, in terms of either male, female or hermaphrodite.'), ...
                PropertyDescriptor('age', '', ...
                'description', 'The time period elapsed since an identifiable point in the life cycle of an organism. If a developmental stage is specified the identifiable point would be the beginning of that stage. Otherwise the identifiable point must be specified. For example, 2 hours post surgery.'), ...
                PropertyDescriptor('developmentStage', '', ...
                'description', 'The developmental stage of the study subject�s life cycle.'), ...
                PropertyDescriptor('subjectIdentifier', '', ...
                'description', 'The unique string which corresponds to the identifier type.'), ...
                PropertyDescriptor('associatedSubjectDetails', '', ...
                'description', 'The organisation (e.g vendor) or individual repsonsible for the subject.'), ...
                PropertyDescriptor('preparationProtocol', '', ...
                'description', 'The surgical procedure or the preparation protocol implmented to obtain the specific sample for recording.'), ...
                PropertyDescriptor('preparationDate', '', ...
                'description', 'The date the surgical procedure or the preparation protocol was performed to obtain the specific sample for recording. Given in the ISO:8601 representation. YYYY-MM-DDThh:mm:ss'), ...
                ];            
        end
        
    end
    
end
