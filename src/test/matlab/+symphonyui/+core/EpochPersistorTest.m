classdef EpochPersistorTest < matlab.unittest.TestCase
    
    properties
        persistor
    end
    
    properties (Constant)
        TEST_FILE = 'test.h5'
        TEST_PURPOSE = 'for testing purposes';
        TEST_START_TIME = datetime([2016,10,24,11,45,07], 'TimeZone', 'America/Denver');
        TEST_END_TIME = datetime([2016,10,24,12,48,32], 'TimeZone', 'Asia/Tokyo');
    end
    
    methods (TestClassSetup)
        
        function classSetup(obj)
            import matlab.unittest.fixtures.PathFixture;
            
            rootPath = fullfile(mfilename('fullpath'), '..', '..', '..', '..', '..', '..');
            
            core = fullfile(rootPath, 'lib', 'Core Framework');
            ui = fullfile(rootPath, 'src', 'main', 'matlab');
            
            obj.applyFixture(PathFixture(core));
            obj.applyFixture(PathFixture(ui));
            
            NET.addAssembly(which('Symphony.Core.dll'));
        end
        
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            cobj = Symphony.Core.H5EpochPersistor.Create(obj.TEST_FILE, obj.TEST_PURPOSE);
            obj.persistor = symphonyui.core.EpochPersistor(cobj);
        end
        
    end
    
    methods (TestMethodTeardown)
        
        function methodTeardown(obj)
            try %#ok<TRYNC>
                obj.persistor.close();
            end
            if exist(obj.TEST_FILE, 'file')
                delete(obj.TEST_FILE);
            end
        end
        
    end
    
    methods (Test)
        
        function testEntityProperties(obj)
            entity = obj.persistor.experiment;
            
            expected = containers.Map();
            expected('uint16') = uint16(12);
            expected('uint16v') = uint16([1 2 3 4 5]);
            expected('uint16m') = uint16([1 2 3; 4 5 6; 7 8 9]);
            expected('double') = 3.5;
            expected('doublev') = [1 2 3 4];
            expected('doublem') = [1 2 3; 4 5 6; 7 8 9];
            expected('string') = 'hello world!';
            
            keys = expected.keys;
            for i = 1:numel(keys)
                entity.addProperty(keys{i}, expected(keys{i}));
            end
            
            obj.verifyEqual(entity.propertiesMap, expected);
        end
        
        function testEntityKeywords(obj)
            entity = obj.persistor.experiment;
            
            expected = {'zam', 'pow', 'taco!', '_+zoooom'};
            
            for i = 1:numel(expected)
                entity.addKeyword(expected{i});
            end
            
            obj.verifyEqual(entity.keywords, expected);
        end
        
        function testEntityNotes(obj)
            entity = obj.persistor.experiment;
            
            time1 = datetime('now', 'TimeZone', 'America/Denver');
            text1 = 'Hi, this is a note about this entity and it is cool';
            entity.addNote(text1, time1);
            
            time2 = datetime('now', 'TimeZone', 'Africa/Johannesburg');
            text2 = 'Hello from Africa!';
            entity.addNote(text2, time2);
            
            note1 = entity.notes{1};
            obj.verifyDatetimesEqual(note1.time, time1);
            obj.verifyEqual(note1.text, text1);
            
            note2 = entity.notes{2};
            obj.verifyDatetimesEqual(note2.time, time2);
            obj.verifyEqual(note2.text, text2);
        end
        
        function testDevice(obj)
            dev = obj.persistor.addDevice('dev', 'man');
            
            obj.verifyEqual(dev.name, 'dev');
            obj.verifyEqual(dev.manufacturer, 'man');
        end
        
        function testSource(obj)
            src = obj.persistor.addSource('src');
            
            obj.verifyEqual(src.label, 'src');
            obj.verifyEmpty(src.sources);
            obj.verifyEmpty(src.epochGroups);
            obj.verifyEmpty(src.allEpochGroups);
            
            src1 = obj.persistor.addSource('src1', src);
            src2 = obj.persistor.addSource('src2', src);
            
            obj.verifyCellsAreEquivalent(src.sources, {src1, src2});
            
            grp1 = obj.persistor.beginEpochGroup('grp1', src);
            grp2 = obj.persistor.beginEpochGroup('grp2', src);
            grp3 = obj.persistor.beginEpochGroup('grp3', src1);
            
            obj.verifyCellsAreEquivalent(src.epochGroups, {grp1, grp2});
            obj.verifyCellsAreEquivalent(src.allEpochGroups, {grp1, grp2, grp3});
        end
        
        function testExperiment(obj)
            exp = obj.persistor.experiment;
            
            obj.verifyEqual(exp.purpose, obj.TEST_PURPOSE);
            obj.verifyEmpty(exp.devices);
            obj.verifyEmpty(exp.sources);
            obj.verifyEmpty(exp.epochGroups);
            
            dev1 = obj.persistor.addDevice('dev1', 'man1');
            dev2 = obj.persistor.addDevice('dev2', 'man2');
            
            obj.verifyCellsAreEquivalent(exp.devices, {dev1, dev2});
            
            src1 = obj.persistor.addSource('src1');
            src2 = obj.persistor.addSource('src2');
            
            obj.verifyCellsAreEquivalent(exp.sources, {src1, src2});
            
            grp1 = obj.persistor.beginEpochGroup('grp1', src1);
            obj.persistor.endEpochGroup();
            grp2 = obj.persistor.beginEpochGroup('grp2', src2);
            
            obj.verifyCellsAreEquivalent(exp.epochGroups, {grp1, grp2});
        end
        
        function testEpochGroup(obj)
            src = obj.persistor.addSource('src');
            grp = obj.persistor.beginEpochGroup('grp', src);
            
            obj.verifyEqual(grp.label, 'grp');
            obj.verifyEqual(grp.source, src);
            obj.verifyEmpty(grp.epochGroups);
            obj.verifyEmpty(grp.epochBlocks);
            
            grp1 = obj.persistor.beginEpochGroup('grp1', src);
            obj.persistor.endEpochGroup();
            grp2 = obj.persistor.beginEpochGroup('grp2', src);
            obj.persistor.endEpochGroup();
            
            obj.verifyCellsAreEquivalent(grp.epochGroups, {grp1, grp2});
            
            blk1 = obj.persistor.beginEpochBlock('blk1', obj.TEST_START_TIME);
            obj.persistor.endEpochBlock(obj.TEST_END_TIME);
            blk2 = obj.persistor.beginEpochBlock('blk2', obj.TEST_START_TIME);
            
            obj.verifyCellsAreEquivalent(grp.epochBlocks, {blk1, blk2});
        end
        
        function testEpochBlock(obj)
            src = obj.persistor.addSource('src');
            grp = obj.persistor.beginEpochGroup('grp', src);
            blk = obj.persistor.beginEpochBlock('blk', obj.TEST_START_TIME);
            
            obj.verifyEqual(blk.protocolId, 'blk');
            obj.verifyEmpty(blk.epochs);
            obj.verifyDatetimesEqual(blk.startTime, obj.TEST_START_TIME);
            obj.verifyEmpty(blk.endTime);
            
            obj.persistor.endEpochBlock(obj.TEST_END_TIME);
            
            obj.verifyDatetimesEqual(blk.endTime, obj.TEST_END_TIME);
        end
        
        function testEpoch(obj)
            error('Need epoch tests');
        end
        
    end
    
    methods
        
        function verifyDatetimesEqual(obj, actual, expected)
            obj.verifyEqual(actual.Year, expected.Year);
            obj.verifyEqual(actual.Month, expected.Month);
            obj.verifyEqual(actual.Day, expected.Day);
            obj.verifyEqual(actual.Hour, expected.Hour);
            obj.verifyEqual(actual.Minute, expected.Minute);
            obj.verifyEqual(actual.Second, expected.Second);
            obj.verifyEqual(actual.Minute, expected.Minute);
            
            actual.Format = 'ZZZZZ';
            expected.Format = 'ZZZZZ';
            obj.verifyEqual(char(actual), char(expected));
        end
        
        function verifyCellsAreEquivalent(obj, actual, expected)
            obj.verifyEqual(numel(actual), numel(expected));
            
            for i = 1:numel(actual)
                equal = zeros(1, numel(expected));
                for j = 1:numel(expected)
                    equal(j) = isequal(actual{i}, expected{j});
                end
                obj.verifyTrue(any(equal));
            end     
        end
        
    end
    
end
