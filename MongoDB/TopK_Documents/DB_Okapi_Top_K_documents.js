DB_Okapi_MR_TopKDocs = function(q_noDocs, q_db, words, k1, b, top) {

    var noDocs = db.documents.count(q_noDocs);
    var avgDL;
    db.documents.aggregate([{ $match: q_noDocs }, { $group: { _id: null, avgDL: { $avg: "$lemmaTextLength" } } }]).forEach(function(elem) { avgDL = elem.avgDL; })

    mapFunctionIDF = function() {
        for (var idx = 0; idx < this.words.length; idx++) {
            if (words.indexOf(this.words[idx].word) != -1) {
                emit(this.words[idx].word, 1);
            }
        }
    };

    reduceFunctionIDF = function(key, values) {
        return Array.sum(values);;
    };

    finalizeFunctionIDF = function(key, reducedVal) {
        reducedVal = (1 + Math.log(noDocs / reducedVal));
        return reducedVal;
    }

    db.documents.mapReduce(mapFunctionIDF, reduceFunctionIDF, { query: q_db, out: "vocabulary", scope: { noDocs: noDocs, words: words }, finalize: finalizeFunctionIDF });

    idfs = db.vocabulary.find().toArray()
    db.vocabulary.drop()
    idfs_word = {}

    for (var idx = 0; idx < idfs.length; idx++) {
        idfs_word[idfs[idx]._id] = idfs[idx].value;
    }

    mapFunctionOkapi = function() {
        for (var idx = 0; idx < this.words.length; idx++) {
            if (words.indexOf(this.words[idx].word) != -1) {
                emit(this._id, (this.words[idx].tf * idf[this.words[idx].word] * (k1 + 1)) / (this.words[idx].tf + k1 * (1 - b + b * (this.lemmaTextLength / avgDL))));
            }
        }
    };

    reduceFunctionOkapi = function(key, values) {
        return Array.sum(values);;
    };

    db.documents.mapReduce(mapFunctionOkapi, reduceFunctionOkapi, { query: q_db, out: "vocabulary", scope: { noDocs: noDocs, words: words, idf: idfs_word, k1: k1, b: b, avgDL: avgDL } });

    var items = db.vocabulary.find().sort({ value: -1, _id: 1 }).limit(top);
    print(items);
    // for (var idx = 0; idx < top; idx++) {
    //     print(items[idx]._id + ' ' + items[idx].value);
    // }
    // while (items.hasNext()) {
    //     var item = items.next();
    //     print(item._id + ' ' + item.value);
    // }

    db.vocabulary.drop()
    return items;
}

//testing function
DB_Okapi_MR_testingFunction = function() {
    startDate = new Date('2015-09-17T00:00:00Z');
    endDate = new Date('2015-09-18T00:00:00Z');
    var k1 = 1.6;
    var b = 0.75
    var top = 10;
    words = [['think'], ['think', 'today'], ['think', 'today', 'friday']];

    for (var idx = 0; idx < words.length; idx++) {
        q1a_noDocs = { gender: 'male' };
        q1a_db = { gender: 'male', "words.word": { $in: words[idx] } };
        q1b_noDocs = { gender: 'female' };
        q1b_db = { gender: 'female', "words.word": { $in: words[idx] } };
        q2a_noDocs = { gender: 'male', date: { $gte: startDate, $lte: endDate } };
        q2a_db = { gender: 'male', date: { $gte: startDate, $lte: endDate }, "words.word": { $in: words[idx] } };
        q2b_noDocs = { gender: 'female', date: { $gte: startDate, $lte: endDate } };
        q2b_db = { gender: 'female', date: { $gte: startDate, $lte: endDate }, "words.word": { $in: words[idx] } };
        q3a_noDocs = { gender: 'male', "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 } };
        q3a_db = { gender: 'male', "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 }, "words.word": { $in: words[idx] } };
        q3b_noDocs = { gender: 'female', "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 } };
        q3b_db = { gender: 'female', "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 }, "words.word": { $in: words[idx] } };
        q4a_noDocs = { gender: 'male', date: { $gte: startDate, $lte: endDate }, "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 } };
        q4a_db = { gender: 'male', date: { $gte: startDate, $lte: endDate }, "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 }, "words.word": { $in: words[idx] } };
        q4b_noDocs = { gender: 'female', date: { $gte: startDate, $lte: endDate }, "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 } };
        q4b_db = { gender: 'female', date: { $gte: startDate, $lte: endDate }, "geoLocation.0": { $gte: 20, $lte: 40 }, "geoLocation.1": { $gte: -100, $lte: 100 }, "words.word": { $in: words[idx] } };

        var times = {
            'male': {
                'q1': new Array(),
                'q2': new Array(),
                'q3': new Array(),
                'q4': new Array()
            },
            'female':
            {
                'q1': new Array(),
                'q2': new Array(),
                'q3': new Array(),
                'q4': new Array()
            }
        };

        db.vocabulary.drop();

        for (i = 0; i < 10; i++) {
            print(i + 1);
            print('Q1 - male');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q1a_noDocs, q1a_db, words[idx], k1, b, top);
            endTime = new Date();
            times['male']['q1'].push(endTime - startTime);
            db.vocabulary.drop();
            print('Q1 - female');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q1b_noDocs, q1b_db, words[idx], k1, b, top);
            endTime = new Date();
            times['female']['q1'].push(endTime - startTime);
            db.vocabulary.drop();
            print('Q2 - male');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q2a_noDocs, q2a_db, words[idx], k1, b, top);
            endTime = new Date();
            times['male']['q2'].push(endTime - startTime);
            db.vocabulary.drop();
            print('Q2 - female');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q2b_noDocs, q2b_db, words[idx], k1, b, top);
            endTime = new Date();
            times['female']['q2'].push(endTime - startTime);
            db.vocabulary.drop();
            print('Q3 - male');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q3a_noDocs, q3a_db, words[idx], k1, b, top);
            endTime = new Date();
            times['male']['q3'].push(endTime - startTime);
            db.vocabulary.drop();
            print('Q3 - female');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q3b_noDocs, q3b_db, words[idx], k1, b, top);
            endTime = new Date();
            times['female']['q3'].push(endTime - startTime);
            db.vocabulary.drop();
            print('Q4 - male');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q4a_noDocs, q4a_db, words[idx], k1, b, top);
            endTime = new Date();
            times['male']['q4'].push(endTime - startTime);
            db.vocabulary.drop();
            print('Q4 - female');
            startTime = new Date();
            DB_Okapi_MR_TopKDocs(q4b_noDocs, q4b_db, words[idx], k1, b, top);
            endTime = new Date();
            times['female']['q4'].push(endTime - startTime);
            db.vocabulary.drop();
        }
        print('DB Okapi MR', words[idx].length, "words");
        print('Q1 - male');
        print(times['male']['q1']);
        print('Q1 - female');
        print(times['female']['q1']);
        print('Q2 - male');
        print(times['male']['q2']);
        print('Q2 - female');
        print(times['female']['q2']);
        print('Q3 - male');
        print(times['male']['q3']);
        print('Q3 - female');
        print(times['female']['q3']);
        print('Q4 - male');
        print(times['male']['q4']);
        print('Q4 - female');
        print(times['female']['q4']);
    }
}

DB_Okapi_MR_testingFunction()
