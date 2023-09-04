/**
 * Created by frans fourie on 2023/07/28.
 */



     const validateIdNumber = (idNumber) => {
        // if the ID number is not valid
        if (checkLuhn(idNumber) === false) {
            return {
                valid: false,
            };
        }

        // finally return the details if the number is valid
        return {
            valid: true,
            gender: parseGender(idNumber),
            DOB: parseDOB(idNumber),
            isCitizen: parseCitizenship(idNumber),
        };
    };

    /**
     * It checks if the ID number is valid.
     * @param idNumber - The ID number to validate.
     * @returns a boolean value.
     */
    const checkLuhn = (idNumber) => {
        let nDigits = idNumber.length;
        let nSum = 0;
        let isSecond = true;
        for (let i = nDigits - 2; i >= 0; i--) {
            let d = parseInt(idNumber.charAt(i));
            if (isSecond === true) {
                d = d * 2;
            }
            if (d > 9) {
                d = d - 9
            }
            nSum += d;

            isSecond = !isSecond;
        }
        return (nSum % 10 === (10 - idNumber.charAt(12)) % 10);
    }

    /** A static method that takes an ID number and returns the gender of the person out of the SSSS sequence. */
     const parseGender = idNumber => {
        const genderCode = idNumber.substring(6, 10);
        const gender = Number(genderCode) < 5000 ? 'female' : 'male';
        return gender;
    };

    /** Checking if the person is a citizen or not. */
     const parseCitizenship = idNumber => {
        const citizenshipCode = idNumber.substring(10, 11);
        const isCitizen = Number(citizenshipCode) === 0;
        return isCitizen;
    }

    /** Getting the date of birth out of the ID number. */
     const parseDOB = idNumber => {
        // get year, and assume the century
        const currentYear = new Date().getFullYear();
        const currentCentury = Math.floor(currentYear / 100) * 100;
        const currentMonth = new Date().getMonth();
        const currentDay = new Date().getDay();

        let yearPart = currentCentury + parseInt(idNumber.substring(0, 2), 10);

        // In Javascript, Jan=0. In ID Numbers, Jan=1.
        const monthPart = parseInt(idNumber.substring(2, 4), 10) - 1;

        const dayPart = parseInt(idNumber.substring(4, 6), 10);

        // only 16 years and above are eligible for an ID
        const eligibleYear = currentYear - 16;
        // make sure the ID's DOB is not below 16 years from today, if so its last century issue
        if (yearPart > eligibleYear || yearPart === eligibleYear && (monthPart > currentMonth || monthPart === currentMonth && dayPart > currentDay)) {
            yearPart -= 100; // must be last century
        }


        const dateOfBirth = new Date(yearPart, monthPart, dayPart);

        // validate that date is in a valid range by making sure that it wasn't 'corrected' during construction
        if (
            !dateOfBirth ||
            dateOfBirth.getFullYear() !== yearPart ||
            dateOfBirth.getMonth() !== monthPart ||
            dateOfBirth.getDate() !== dayPart
        ) {
            return undefined;
        }
        return dateOfBirth;

}

export {validateIdNumber}